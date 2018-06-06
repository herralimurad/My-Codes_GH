using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;
using EmailSheduleService;
namespace accountMonitor
{
   public  class EmailController


    {


        public void SendEmail(string to, string fromUser, string fromPwd, string emailSubject,
     string emailBody, string emailAttchmentPath, string emailAttachmentName
     )
        {
            try
            {
                var fromAddress = new MailAddress(fromUser);
                var toAddress = new MailAddress(to);
                var smtp = new SmtpClient
                {
                    Host = "smtp.gmail.com",
                    Port = 587,
                    EnableSsl = true,
                    DeliveryMethod = SmtpDeliveryMethod.Network,
                    Credentials = new NetworkCredential(fromAddress.Address, fromPwd),
                    Timeout = 20000
                };
                using (var message = new MailMessage(fromAddress, toAddress)
                {
                    Subject = emailSubject,
                    Body = emailBody,
                })

                {
                    message.Attachments.Add(new Attachment(emailAttchmentPath + emailAttachmentName));
                    smtp.Send(message);
                }
            }
            catch (Exception e)
            {
                LogLine(e.StackTrace);
            }


        }

        public static void LogLine(string message)
        {

            File.AppendAllText(@"C:\Users\Ali Murad\Desktop\log.txt", message + "\n");
        }
    }
}
