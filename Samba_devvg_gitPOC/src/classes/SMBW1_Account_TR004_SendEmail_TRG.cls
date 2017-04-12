/*******************************************************
Created by J. Hazebrouck
Associated Business Requirement: BR-52
Send an email to Ultimate Account Owner when a new account
is assigned to their hierarchy
*******************************************************/
public without sharing class SMBW1_Account_TR004_SendEmail_TRG {

	public static void SendEmailToUltimate(List<Id> listAccId){
		//Get ultimate parent email for all accounts
		List<Account> listAcc = [SELECT Id, Name, Ultimate_Parent_Account__c, Ultimate_Parent_Account__r.OwnerId,
		Ultimate_Parent_Account__r.Owner.Email, LastModifiedById, LastModifiedBy.Name FROM Account WHERE Id IN: listAccId];
		List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
		List<EmailTemplate> listTemplateId = [SELECT Id, Body, Subject FROM EmailTemplate
		WHERE name =: 'SMB_ACC_EmailTemplate_NotifyUltimateAccountOwner' limit 1];
		
		for(Account a : listAcc){
			if(a.Ultimate_Parent_Account__r.Owner.Email != null){
				//Preparing the email that will be sent to the ultimate parent account owner
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				List<String> listToAddress = new List<String>();
				listToAddress.add(a.Ultimate_Parent_Account__r.Owner.Email);
				mail.setToAddresses(listToAddress);
				String messageBody = listTemplateId[0].Body;
				messageBody = messageBody.replace('[Account.Name]', a.Name);
				messageBody = messageBody.replace('[Account.LastModifiedBy]', a.LastModifiedBy.Name);
				mail.setSubject(listTemplateId[0].Subject);
				mail.setPlainTextBody(messageBody);
				allmsg.add(mail);
			}
		}
		Messaging.sendEmail(allmsg);
	}
}