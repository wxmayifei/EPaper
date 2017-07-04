using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

namespace EPaper.Models
{
    [Table("EPapers")]
    public class EPaper
    {
        [Key]
        public int ID
        {
            get; set;
        }

        public string Path
        {
            get; set;
        }

        public string BigThumbPath
        {
            get; set;
        }

        public string ThumbPath
        {
            get; set;
        }

        public DateTime CreateTime
        {
            get; set;
        }

        public string Size
        {
            get; set;
        }
        
        [ForeignKey("EPaperID")]
        public virtual ICollection<EPaperDetail> EPaperDetails
        {
            get; set;
        }
    }
}