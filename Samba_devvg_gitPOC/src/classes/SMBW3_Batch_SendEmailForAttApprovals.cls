global class SMBW3_Batch_SendEmailForAttApprovals implements Database.Batchable<sObject>, Schedulable{
   

   
    global void execute(SchedulableContext SC) {

        Database.executebatch(this, 1 );
    }
    

    global Database.QueryLocator start(Database.BatchableContext BC){

    return Database.getQueryLocator('SELECT Id, Name, Approve__c, Reject__c, Opportunity__c FROM Master_Attachment_Approval__c WHERE (Approve__c=true) AND (LastModifiedDate= LAST_N_DAYS:1)');
        
    }

    global void execute(Database.BatchableContext BC, List<Master_Attachment_Approval__c> scope){

            Set<Id> oppIds=new Set<Id>();

            for (Master_Attachment_Approval__c ma: scope) {
                oppIds.add(ma.Opportunity__c);
            }

            List<User> usrList=SMBW3_EmailToOppTeamMembers.retrieveUsers(oppIds);

            //Send Emails
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            
            Integer emailSendLimit = Integer.valueOf(Label.SMB_CL029_EmailSendLimit);
           EmailTemplate eTemplate = [Select Id from EmailTemplate where Name = :System.Label.SMBW3_CL009_OppMasterAttachAppMail];
            Integer emailCount=0;
            for ( User usr: usrList ) {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

              mail.setWhatId( scope[0].id );
              mail.setTargetObjectId(usr.id);
              mail.setTemplateId(eTemplate.id);
              mail.setSaveAsActivity(false);
              mailList.add(mail);
              
              if (++emailCount>emailSendLimit){
                         Messaging.sendEmail(mailList);
                         mailList.clear();
                         emailCount=0;
               }
            }
        
            if ( !(emailCount>emailSendLimit) && emailCount!=0 ){
                             Messaging.sendEmail(mailList);
                             mailList.clear();
                             emailCount=0;
            }
    }
    

    global void finish(Database.BatchableContext BC){
        
    }
}