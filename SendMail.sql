CREATE OR REPLACE AND RESOLVE JAVA SOURCE NAMED "SendMail" AS
package pkg_edi_email;
/*--------------------------------------------------------------------------------
  -- Program      : PKG_EDI_SCHEDULER
  --
  -- Date         : 15th November 2007
  -- Author       : Sandeep Kumar
  --
  -- Description  : This java source to Send Mail.
  --
  --
  --
  -- Quick Update : @c:\SendMail.sql
  --
  -- CHANGE HISTORY
  -- Date         Author   Version     Ref           			   Description
  -- 23/Apr/08    SK,SR     1.0       RCL-6268/PD_CR080402-03      Initial Revision
  --------------------------------------------------------------------------------*/
  
  import java.util.*;
  import java.io.*;
  import javax.mail.*;
  import javax.mail.internet.*;
  import javax.activation.*;
  public class SendMail {
     /* Sender, Recipient, CCRecipient, and BccRecipient are comma-separated */
     /*  lists of addresses. Body can span multiple CR/LF-separated lines. */
     /*  Attachments is a ///-separated list of file names. */
     public static int Send(String SMTPServer,
                            String Sender,
                            String Recipient,
                            String CcRecipient,
                            String BccRecipient,
                            String Subject,
                            String Body,
                            String ErrorMessage[],
                            String Attachments) {
       /* Error status; */
        int ErrorStatus = 0;

        /* Create some properties and get the default Session; */
        Properties props = System.getProperties();
        props.put("mail.smtp.host", SMTPServer);
        Session session = Session.getDefaultInstance(props, null);

        try {
           /* Create a message. */
           MimeMessage msg = new MimeMessage(session);

           /* extracts the senders and adds them to the message. */
           /* Sender is a comma-separated list of e-mail addresses as per RFC822. */
           {
              InternetAddress[] TheAddresses = InternetAddress.parse(Sender);
              msg.addFrom(TheAddresses);
           }

           /* Extract the recipients and assign them to the message. */
           /* Recipient is a comma-separated list of e-mail addresses as per RFC822. */
           {
              InternetAddress[] TheAddresses = InternetAddress.parse(Recipient);
              msg.addRecipients(Message.RecipientType.TO,TheAddresses);
           }

           /* Extract the Cc-recipients and assign them to the message; */
           /* CcRecipient is a comma-separated list of e-mail addresses as per RFC822 */
           if (null != CcRecipient) {
              InternetAddress[] TheAddresses = InternetAddress.parse(CcRecipient);
              msg.addRecipients(Message.RecipientType.CC,TheAddresses);
           }

           /* Extract the Bcc-recipients and assign them to the message; */
           /* BccRecipient is a comma-separated list of e-mail addresses as per RFC822 */
           if (null != BccRecipient) {
              InternetAddress[] TheAddresses = InternetAddress.parse(BccRecipient);
              msg.addRecipients(Message.RecipientType.BCC,TheAddresses);
           }

           /* Subject field */
           msg.setSubject(Subject);

           /* Create the Multipart to be added the parts to */
           Multipart mp = new MimeMultipart();

           /* Create and fill the first message part */
           {
              MimeBodyPart mbp = new MimeBodyPart();
              mbp.setText(Body);

              /*Attach the part to the multipart; */
              mp.addBodyPart(mbp);
           }

           /* Attach the files to the message */
           if (null != Attachments) {
              int StartIndex = 0, PosIndex = 0;
              while (-1 != (PosIndex = Attachments.indexOf("///",StartIndex))) {
                 /* Create and fill other message parts; */
                 MimeBodyPart mbp = new MimeBodyPart();
                 FileDataSource fds =
                 new FileDataSource(Attachments.substring(StartIndex,PosIndex));
                 mbp.setDataHandler(new DataHandler(fds));
                 mbp.setFileName(fds.getName());
                 mp.addBodyPart(mbp);
                 PosIndex += 3;
                 StartIndex = PosIndex;
              }
              /* Last, or only, attachment file; */
              if (StartIndex < Attachments.length()) {
                 MimeBodyPart mbp = new MimeBodyPart();
                 FileDataSource fds = new FileDataSource(Attachments.substring(StartIndex));
                 mbp.setDataHandler(new DataHandler(fds));
                 mbp.setFileName(fds.getName());
                 mp.addBodyPart(mbp);
              }
           }

           /* Add the Multipart to the message */
           msg.setContent(mp);

           /* Set the Date: header */
           msg.setSentDate(new Date());

           /* Send the message; */
           Transport.send(msg);
        } catch (MessagingException MsgException) {
           ErrorMessage[0] = MsgException.toString();
           Exception TheException = null;
           if ((TheException = MsgException.getNextException()) != null)
             ErrorMessage[0] = ErrorMessage[0] + "\n" + TheException.toString();
             ErrorStatus = 1;
        }
        return ErrorStatus;
     } /* End Send Class */
  } /* End of public class SendMail */
/
