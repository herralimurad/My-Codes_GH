using accountMonitor;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using System.Timers;

namespace EmailSheduleService
{
    public partial class EmailSheduleService : ServiceBase
    {
        private Timer _timer = new Timer();
        DateTime _alaramTime = DateTime.Parse("2012/12/12 22:00:00.000");

        const string subFolder1           =    "Ultra";
        const string subFolder2           =    "0. General";
		const string emailAttchmentPath   =   "C:\\Users\\Public\\Documents\\"+ subFolder1 + "\\"+ subFolder2 + "";
        const string emailAttachmentName  =   "\\portfolio.json";

        public EmailSheduleService()
        {
            InitializeComponent();
        
        }

        protected override void OnStart(string[] args)
        {

			 // Create Path if doesn't Exist
            System.IO.Directory.CreateDirectory("C:\\Users\\Public\\Documents\\" + subFolder1);
            System.IO.Directory.CreateDirectory(emailAttchmentPath);
            File.AppendAllText(@""+ emailAttchmentPath + emailAttachmentName+"", "");
			
			

             LogLine("Service Started : " + DateTime.UtcNow.ToString()+ " UTC");
            _timer.Interval = 1000;
            _timer.Elapsed += Tick;
            _timer.Start();
          }

        private void Tick(object sender, ElapsedEventArgs e)
        {

            const string to = "ali.murad1995@gmail.com";
            const string fromUser = "herralimurad@gmail.com";
            const string fromPwd = "Germany1,";
            const string emailSubject = "Investor balance update";
            const string emailBody = "Investor balance updated on: ";
            

            DateTime compareDate = TrimMilliseconds();
            if (TimeSpan.Compare(compareDate.TimeOfDay, _alaramTime.TimeOfDay) == 0)
            {
                try
                {
                    EmailController ec = new EmailController();
					
					
					
                    ec.SendEmail(to, fromUser, fromPwd, emailSubject, emailBody + DateTime.UtcNow + " UTC",
                    emailAttchmentPath, emailAttachmentName);
                    LogLine("Email Sent : " + DateTime.UtcNow.ToString() + " UTC" + "\n");
                }
                catch (Exception err) {
                    LogLine(err.StackTrace + "\n");
                }

            }
        }

        public static DateTime TrimMilliseconds( )
        {
            DateTime dt = DateTime.UtcNow;
            return new DateTime(dt.Year, dt.Month, dt.Day, dt.Hour, dt.Minute, dt.Second, 0);
        }

        public static void LogLine(string message) {


            File.AppendAllText(emailAttchmentPath+"//EmailSender.log", message+ "\n");
    }

        protected override void OnStop()
        {
        }
    }
}
