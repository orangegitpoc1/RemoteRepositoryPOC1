@isTest
public class SMB_AccountManagerMapping_Test{
    
    public static testMethod void insertMarketingManager(){
       Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Bypass_WF__c=true,SMB_Sales_Region__c='',SMB_Sales_Cluster__c='');
        
       System.runAs(u){
          TestDataCreation.CreateMarketingManager(null);
          TestDataCreation.createAccounts(1);
          System.assert(TestDataCreation.CreateMarketingManager(null).size()>0);
      //    System.assert(TestDataCreation.createAccounts(1).size()>0);
       }
       
       
       }
       
       public static testMethod void insertMarketingManagerwithusercluster(){
       Profile p = [SELECT Id FROM Profile WHERE Name='Regional Administrator User SAMBA'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Bypass_WF__c=true,SMB_Sales_Region__c='',SMB_Sales_Cluster__c='OCB');
        
       System.runAs(u){
          TestDataCreation.CreateMarketingManager(u);
          TestDataCreation.createAccounts(1);
          System.assert(TestDataCreation.CreateMarketingManager(null).size()>0);
       //   System.assert(TestDataCreation.createAccounts(1).size()>0);
       }
       
       
       }
       
       public static testMethod void UpdateMarketingManager(){
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Bypass_WF__c=true,SMB_Sales_Region__c='APAC',SMB_Sales_Cluster__c='');
        
       System.runAs(u){
          TestDataCreation.CreateMarketingManager(null);
          list<Account> Acc=TestDataCreation.createAccounts(1);
          User u1 = new User
           (Alias = 'standt2', Email='standarduser12@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing12', 
           LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId =p.Id, TimeZoneSidKey='America/Los_Angeles', 
           UserName='abcdeg2@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Bypass_WF__c=true,SMB_Sales_Cluster__c='');
           insert u1;
           system.debug('uuuuuuuuuuuuuu'+u1.id);
           Acc[0].Ownerid=u1.id;
           update Acc[0];
                    
            
       }
       
       
       }
       
       public static testMethod void UpdateMarketingManagerwithcluster(){
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Bypass_WF__c=true,SMB_Sales_Region__c='',SMB_Sales_Cluster__c='OCB');
        
       System.runAs(u){
          Profile p1 = [SELECT Id FROM Profile WHERE Name='Regional Administrator User SAMBA'];
          User u1 = new User
           (Alias = 'standt2', Email='standarduser12@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing12', 
           LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId =p1.Id, TimeZoneSidKey='America/Los_Angeles', 
           UserName='abcdeg2@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Cluster__c='OCB');
           insert u1; 
          TestDataCreation.CreateMarketingManager(u1);
          list<Account> Ac=TestDataCreation.createAccounts(1);
          
           system.debug('uuuuuuuuuuuuuu'+u1.id);
           Ac[0].Ownerid=u1.id;
           update Ac[0];
           System.assert(TestDataCreation.CreateMarketingManager(u1).size()>0);
       //   System.assert(TestDataCreation.createAccounts(1).size()>0);
           
            
       }
       
       
       }
       
       public static testMethod void UpdatecontactMarketingManager(){
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,SMB_Bypass_WF__c=true,PAD_BypassTrigger__c='',SMB_Sales_Cluster__c='');
        
       System.runAs(u){
          Profile p1 = [SELECT Id FROM Profile WHERE Name='Regional Administrator User SAMBA'];
          
          User u1 = new User
           (Alias = 'standt2', Email='standarduser12@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing12', 
           LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId =p1.Id, TimeZoneSidKey='America/Los_Angeles', 
           UserName='abcdeg2@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Cluster__c='OCB');
           insert u1;

          User u2 = new User
           (Alias = 'standt2', Email='stndrdTestUser212345@testorg1.com', EmailEncodingKey='UTF-8', LastName='Testing112', 
           LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId =p1.Id, TimeZoneSidKey='America/Los_Angeles', 
           UserName='stndrdTestUser212345@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Region__c='APAC',SMB_Sales_Cluster__c='');
           insert u2;

          TestDataCreation.CreateMarketingManager(u1);
          list<Account> Ac=TestDataCreation.createAccounts(1);
          list<Contact> cont=TestDataCreation.createContactsWithAccount(2,Ac[0].id,'check');
          system.debug('Ac.Marketing_Manager__c'+Ac[0].Marketing_Manager__c);
          system.debug('cont'+cont);
          system.debug('Ac'+Ac);
          
          Ac[0].OwnerId=u2.id;
           update Ac[0];
           
          system.debug('Ac.Marketing_Manager__c'+Ac[0].Marketing_Manager__c);
          
          TestDataCreation.CreateMarketingManager(u2);
          Ac[0].Marketing_Manager__c=u2.id;
           update Ac[0];
           
            system.debug('Ac.Marketing_Manager__c'+Ac[0].Marketing_Manager__c);
          
           
           System.assert(TestDataCreation.CreateMarketingManager(u).size()>0);
       //   System.assert(TestDataCreation.createAccounts(1).size()>0);
           
            
       }
       
       
       }
       
       
       
 
       
        Public static testMethod void CatchExceptionTestcover(){
         Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Cluster__c='');
        
       System.runAs(u){
         try{
          Account acco= new Account(); 
          insert acco;
          update acco;
          }
          Catch(DmlException e){
           System.assert(e.getMessage().contains(' First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing:'),e.getMessage());
           System.assertEquals('REQUIRED_FIELD_MISSING',e.getDmlStatusCode(0));


           
          }
        }
        }
   }