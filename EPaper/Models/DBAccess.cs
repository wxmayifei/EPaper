using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Migrations;
using System.Linq;
using System.Web;

namespace EPaper.Models
{
    public class DBAccess : DbContext
    {
        static DBAccess()
        {
            Database.SetInitializer<DBAccess>(null);
        }

        public DBAccess() : base("default")
        {

        }

        public DbSet<EPaper> EPapers
        {
            get; set;
        }

        public DbSet<EPaperDetail> EPaperDetails
        {
            get; set;
        }
    }
}