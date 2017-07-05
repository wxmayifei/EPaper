using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Web;

namespace EPaper
{
    /// <summary>
    /// Process 的摘要说明
    /// </summary>
    public class Process : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            var m = context.Request.Form["m"];
            switch (m)
            {
                case "SaveEPaper":
                    SaveEPaper(context);
                    break;
                case "DeleteEPaper":
                    DeleteEPaper(context);
                    break;
                case "GetEPaperDetails":
                    GetEPaperDetails(context);
                    break;
                case "GetEPaper":
                    GetEPaper(context);
                    break;
                case "GetTopEPapers":
                    GetTopEPapers(context);
                    break;
            }
            context.Response.End();
        }

        public void SaveEPaper(HttpContext context)
        {
            RemoveExtraImages(context.Server.MapPath("~/EPapers/Temp"));
            var dataID = 0;
            try
            {
                dataID = Convert.ToInt32(context.Request.Form["dataid"]);
            }
            catch { }
            //process image
            var rootPath = context.Server.MapPath("~/EPapers");
            var file = "";
            Models.EPaper ePaper = null;
            var isNew = false;
            using (var dbContext = new Models.DBAccess())
            {
                if (dataID > 0)
                {
                    ePaper = dbContext.EPapers.FirstOrDefault(m => m.ID == dataID);
                }
                if (ePaper == null)
                {
                    file = Path.Combine(rootPath, "Temp", Path.GetFileName(context.Request.Form["image"]));
                }
                else
                {
                    file = Path.Combine(rootPath, ePaper.Path);
                }
                if (!File.Exists(file))
                {
                    context.Response.Write(JsonConvert.SerializeObject(new Models.ReturnResult() { IsSuccess = false, Message = "Couldn't find EPaper" }));
                    return;
                }
                //save to DB
                var shapes = JArray.Parse(context.Request.Form["shapes"]);
                var prefixPath = DateTime.Now.ToString("yyyy/MM/dd");
                var storeDir = Path.Combine(rootPath, prefixPath);
                if (!Directory.Exists(storeDir))
                {
                    Directory.CreateDirectory(storeDir);
                }
                var extenstion = Path.GetExtension(file);
                using (var image = Image.FromFile(file))
                {
                    if (ePaper == null)
                    {
                        isNew = true;
                        ePaper = new Models.EPaper()
                        {
                            CreateTime = DateTime.Now
                        };
                        var strSize = "{\"x\":" + image.Width + ",\"y\":" + image.Height;
                        ePaper.Path = prefixPath + "/" + Guid.NewGuid().ToString() + extenstion;
                        var size = GetSize(image.Width, image.Height, 180, 135);
                        strSize += ",\"x1\":" + size.Item1 + ",\"y1\":" + size.Item2;
                        var thumbImage = image.GetThumbnailImage(size.Item1, size.Item2, () => { return false; }, IntPtr.Zero);
                        ePaper.ThumbPath = prefixPath + "/" + Guid.NewGuid().ToString() + extenstion;
                        thumbImage.Save(Path.Combine(rootPath, ePaper.ThumbPath));
                        size = GetSize(image.Width, image.Height, 660, 880);
                        strSize += ",\"x2\":" + size.Item1 + ",\"y2\":" + size.Item2 + "}";
                        thumbImage = image.GetThumbnailImage(size.Item1, size.Item2, () => { return false; }, IntPtr.Zero);
                        ePaper.BigThumbPath = prefixPath + "/" + Guid.NewGuid().ToString() + extenstion;
                        thumbImage.Save(Path.Combine(rootPath, ePaper.BigThumbPath));
                        ePaper.Size = strSize;
                        dbContext.EPapers.Add(ePaper);
                        dbContext.SaveChanges();
                    }
                    foreach (var item in shapes)
                    {
                        Models.EPaperDetail detail = null;
                        var detailID = item.Value<int>("dataid");
                        if (detailID > 0)
                        {
                            detail = ePaper.EPaperDetails.FirstOrDefault(m => m.ID == detailID);
                        }
                        if (item.Value<string>("type") == "rect")
                        {
                            if (detail == null)
                            {
                                detail = new Models.EPaperDetail()
                                {
                                    EPaperID = ePaper.ID,
                                    Shape = JsonConvert.SerializeObject(item),
                                    Path = prefixPath + "/" + Guid.NewGuid().ToString() + extenstion
                                };
                                dbContext.EPaperDetails.Add(detail);
                            }
                            else
                            {
                                TryDeleteFile(Path.Combine(rootPath, detail.Path));
                            }
                            detail.Shape = JsonConvert.SerializeObject(item);
                            using (Image block = CutImage(image, item.Value<int>("x"), item.Value<int>("y"), item.Value<int>("width"), item.Value<int>("height")))
                            {
                                block.Save(Path.Combine(rootPath, detail.Path));
                            }
                        }
                    }
                    for (var i = 0; i < ePaper.EPaperDetails.Count; i++)
                    {
                        if (shapes.FirstOrDefault(m => m.Value<int>("dataid") == ePaper.EPaperDetails.ElementAt(i).ID) == null)
                        {
                            dbContext.EPaperDetails.Remove(ePaper.EPaperDetails.ElementAt(i));
                            i--;
                        }
                    }
                    dbContext.SaveChanges();
                }
            }
            if (isNew)
            {
                File.Move(file, Path.Combine(rootPath, ePaper.Path));
            }
        }

        private Image CutImage(Image source, int x, int y, int width, int height)
        {
            Bitmap bitmap = new Bitmap(width, height);
            Graphics graphic = Graphics.FromImage(bitmap);
            graphic.DrawImage(source, 0, 0, new Rectangle(x, y, width, height), GraphicsUnit.Pixel);
            return bitmap;
        }

        private Tuple<int, int> GetSize(int imgWidth, int imgHeight, int maxWidth, int maxHeight)
        {
            if (imgHeight > maxHeight || imgWidth > maxWidth)
            {
                if (imgWidth > imgHeight)
                {
                    //以宽度为准
                    return new Tuple<int, int>(maxWidth, imgHeight * maxWidth / imgWidth);
                }
                else
                {
                    return new Tuple<int, int>(imgWidth * maxHeight / imgHeight, maxHeight);
                }
            }
            return new Tuple<int, int>(imgWidth, imgHeight);
        }

        private void RemoveExtraImages(string path)
        {
            //remove the images which uploaded over 24 hours
            var files = Directory.GetFiles(path);
            for (var i = 0; i < files.Length; i++)
            {
                if ((DateTime.Now - File.GetCreationTime(files[i])).TotalHours > 24)
                {
                    TryDeleteFile(files[i]);
                    i--;
                }
            }
        }

        private void GetEPaperDetails(HttpContext context)
        {
            var id = Convert.ToInt32(context.Request.Form["id"]);
            using (var dbContext = new Models.DBAccess())
            {
                context.Response.Write(JsonConvert.SerializeObject(dbContext.EPaperDetails.Where(m => m.EPaperID == id).Select(m => new { m.ID, m.Shape, m.Path }).ToList()));
            }
        }

        private void DeleteEPaper(HttpContext context)
        {
            var id = Convert.ToInt32(context.Request.Form["id"]);
            var rootPath = context.Server.MapPath("~/EPapers");
            using (var dbContext = new Models.DBAccess())
            {
                var epaper = dbContext.EPapers.FirstOrDefault(m => m.ID == id);
                if (epaper == null)
                {
                    return;
                }
                TryDeleteFile(Path.Combine(rootPath, epaper.Path));
                TryDeleteFile(Path.Combine(rootPath, epaper.ThumbPath));
                TryDeleteFile(Path.Combine(rootPath, epaper.BigThumbPath));
                foreach (var detail in epaper.EPaperDetails)
                {
                    TryDeleteFile(Path.Combine(rootPath, detail.Path));
                }
                dbContext.EPaperDetails.RemoveRange(epaper.EPaperDetails);
                dbContext.EPapers.Remove(epaper);
                dbContext.SaveChanges();
            }
        }

        private void GetTopEPapers(HttpContext context)
        {
            using (var dbContext = new Models.DBAccess())
            {
                context.Response.Write(JsonConvert.SerializeObject(dbContext.EPapers.OrderByDescending(m => m.CreateTime).Take(20).Select(m => new { m.ID, m.BigThumbPath, m.ThumbPath, m.CreateTime, m.Size }).ToList()));
            }
        }

        private void GetEPaper(HttpContext context)
        {
            var id = Convert.ToInt32(context.Request.Form["id"]);
            using (var dbContext = new Models.DBAccess())
            {
                var epaper = dbContext.EPapers.FirstOrDefault(m => m.ID == id);
                if (epaper == null)
                {
                    return;
                }
                epaper.EPaperDetails.ToList();
                context.Response.Write(JsonConvert.SerializeObject(epaper, new JsonSerializerSettings() { ReferenceLoopHandling = ReferenceLoopHandling.Ignore }));
            }
        }

        private void TryDeleteFile(string path)
        {
            try
            {
                File.Delete(path);
            }
            catch { }
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}