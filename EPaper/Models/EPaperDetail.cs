using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

namespace EPaper.Models
{
    [Table("EPaperDetails")]
    public class EPaperDetail
    {
        [Key]
        public int ID
        {
            get; set;
        }

        public int EPaperID
        {
            get; set;
        }

        public string Path
        {
            get; set;
        }

        public string Shape
        {
            get; set;
        }

        [ForeignKey("EPaperID")]
        public EPaper EPaper
        {
            get; set;
        }
    }
}