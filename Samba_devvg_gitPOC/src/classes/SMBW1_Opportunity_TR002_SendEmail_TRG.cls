/*******************************************************
Created by J. Hazebrouck
Associated Business Requirement: BR-19
Send an email to Account owner and Ultimate Account Owner everytime
an opportunity is created
*******************************************************/
public without sharing class SMBW1_Opportunity_TR002_SendEmail_TRG {

    public static void SendEmailToTeam(List<Id> listOppId){
        //Get opportunity owner, account owner and ultimate parent email for all opportunities
        List<Opportunity> listOpp = [SELECT Id, Name, AccountId, Account.OwnerId, Account.Owner.Email,
        Account.Ultimate_Parent_Account__c, Account.Ultimate_Parent_Account__r.OwnerId, OwnerId, Owner.Email,
        Account.Ultimate_Parent_Account__r.Owner.Email, CreatedById, LastModifiedById, LastModifiedBy.Name,
        Opportunity_18_ID__c, SMB_OPP_Public_Opportunity_ID__c, Account.Name, SMB_OPP_OID_TECK__c, E_Force_ID__c 
        FROM Opportunity WHERE Id IN: listOppId];
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> listTemplateId = [SELECT Id, Body, Subject, HTMLValue FROM EmailTemplate
        WHERE name =: 'SMB_opp_email_notification_creation_HTML' limit 1];
        
        for(Opportunity o : listOpp){
            if(o.CreatedById != o.Account.OwnerId){
                //Preparing the email that will be sent to the opportunity owner, account owner and ultimate parent account owner
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> listToAddress = new List<String>();
                if(o.Account.Owner.Email != null)
                    listToAddress.add(o.Account.Owner.Email);
                //Adding first condition as mentioned on Chatter Feed of UST-01208    
                if(o.Account.Ultimate_Parent_Account__r.OwnerId != o.Account.OwnerId && o.Account.Ultimate_Parent_Account__r.Owner.Email != null)
                    listToAddress.add(o.Account.Ultimate_Parent_Account__r.Owner.Email);
                mail.setToAddresses(listToAddress);
                String messageBodyHTML = listTemplateId[0].HTMLValue;
                //if(o.SMB_OPP_Public_Opportunity_ID__c != null){
                    messageBodyHTML = messageBodyHTML.replace('{!Opportunity.Name}', o.Name);
                    messageBodyHTML = messageBodyHTML.replace('{!Opportunity.SMB_OPP_Public_Opportunity_ID__c}', o.E_Force_ID__c!=null?o.E_Force_ID__c:o.SMB_OPP_OID_TECK__c);
                /*}else{
                    messageBodyHTML = messageBodyHTML.replace('{!Opportunity.Name} (Public Opportunity Id : {!Opportunity.SMB_OPP_Public_Opportunity_ID__c})', o.Name);                    
                }*/
                                                
                messageBodyHTML = messageBodyHTML.replace('{!Opportunity.LastModifiedBy}', o.LastModifiedBy.Name);         
                messageBodyHTML = messageBodyHTML.replace('{!Opportunity.Account}', o.Account.Name);
                messageBodyHTML = messageBodyHTML.replace('{!Opportunity.Opportunity_18_ID__c}', o.Opportunity_18_ID__c);
                mail.setSubject(listTemplateId[0].Subject);
                mail.setHtmlBody(messageBodyHTML);
                allmsg.add(mail);
            }
        }
        Messaging.sendEmail(allmsg);
    }
}