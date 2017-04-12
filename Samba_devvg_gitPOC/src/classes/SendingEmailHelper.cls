public class SendingEmailHelper {

    public static Messaging.SingleEmailMessage processEmail
    (Id userId, String subject, String htmlBdy, Id templateId, Id whatId)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(userId);
        mail.setSaveAsActivity(false);
        if(templateId != null){
            mail.setTemplateId(templateId);
        }
        if(htmlBdy!=null){
            mail.setHtmlBody(htmlBdy);
        }
        if(subject!=null){
            mail.setSubject(subject);
        }
        if(whatId!=null){
            mail.setWhatId(whatId);
        }
        return mail;
    }

}