@isTest
public class SMB_LeadManagerMapping_Test{
    
    public static testMethod void insertMarketingManager(){
       Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Region__c='',SMB_Sales_Cluster__c='');
        
       System.runAs(u){
          TestDataCreation.CreateMarketingManager(null);
          TestDataCreation.CreateLead();
          System.assert(TestDataCreation.CreateMarketingManager(null).size()>0);
          System.assert(TestDataCreation.CreateLead().size()>0);
       }
       
       
       }
       
       public static testMethod void insertMarketingManagerWith_Queue_Owner(){
       Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Region__c='',SMB_Sales_Cluster__c='');
        
       System.runAs(u){
          TestDataCreation.CreateMarketingManager(null);
          
          List<Lead> LAD=TestDataCreation.CreateLeadwithqueueOwner();
          List<QueueSobject> QueueSobject_Queue_Id=[SELECT Id,Queue.name,QueueId,SobjectType FROM QueueSobject WHERE SobjectType = 'lead' and Queue.name='APAC'];
          List<QueueSobject> ListQueue_Id=[SELECT Id,Queue.name,QueueId,SobjectType FROM QueueSobject WHERE SobjectType = 'lead'];
          LAD[0].Ownerid=ListQueue_Id[4].QueueId;
          Update LAD[0]; 
          LAD[1].Ownerid=QueueSobject_Queue_Id[0].QueueId; 
          Update LAD[1];        
          System.assert(TestDataCreation.CreateMarketingManager(null).size()>0);
          System.assert(TestDataCreation.CreateLead().size()>0);
       }
       
       
       }
       
       public static testMethod void insertMarketingManagerwithusercluster(){
       Profile p = [SELECT Id FROM Profile WHERE Name='Regional Administrator User SAMBA'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Region__c='',SMB_Sales_Cluster__c='OCB');
        
       System.runAs(u){
          TestDataCreation.CreateMarketingManager(u);
          TestDataCreation.CreateLead();
          System.assert(TestDataCreation.CreateMarketingManager(null).size()>0);
          System.assert(TestDataCreation.CreateLead().size()>0);
       }
       
       
       }
       
       public static testMethod void insertMarketingManagerwithuserRegion(){
       Profile p = [SELECT Id FROM Profile WHERE Name='Regional Administrator User SAMBA'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Cluster__c='',SMB_Sales_Region__c='APAC');
        
       System.runAs(u){
          TestDataCreation.CreateMarketingManager(u);
          TestDataCreation.CreateLead();
          System.assert(TestDataCreation.CreateMarketingManager(null).size()>0);
          System.assert(TestDataCreation.CreateLead().size()>0);
       }
       
       
       }
       
       
       public static testMethod void UpdateMarketingManager(){
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Cluster__c='');
        
       System.runAs(u){
          TestDataCreation.CreateMarketingManager(null);
          list<lead> ld=TestDataCreation.CreateLead();
          TestDataCreation.CreateQueue();
          User u1 = new User
           (Alias = 'standt2', Email='standarduser12@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing12', 
           LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId =p.Id, TimeZoneSidKey='America/Los_Angeles', 
           UserName='abcdeg2@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Cluster__c='');
           insert u1;
           system.debug('uuuuuuuuuuuuuu'+u1.id);
           ld[0].Ownerid=u1.id;
           update ld[0];
                    
            
       }
       
       
       }
       
       public static testMethod void UpdateMarketingManagerwithcluster(){
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Cluster__c='OCB');
        
       System.runAs(u){
          Profile p1 = [SELECT Id FROM Profile WHERE Name='Regional Administrator User SAMBA'];
          User u1 = new User
           (Alias = 'standt2', Email='standarduser12@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing12', 
           LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId =p1.Id, TimeZoneSidKey='America/Los_Angeles', 
           UserName='abcdeg2@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Cluster__c='OCB');
           insert u1; 
          TestDataCreation.CreateMarketingManager(u1);
          list<lead> ld=TestDataCreation.CreateLead();
          TestDataCreation.CreateQueue();
          
           system.debug('uuuuuuuuuuuuuu'+u1.id);
           ld[0].Ownerid=u1.id;
           update ld[0];
           System.assert(TestDataCreation.CreateMarketingManager(u1).size()>0);
          System.assert(TestDataCreation.CreateLead().size()>0);
           
            
       }
       
       
       }
       
       
       
       
       Public static testMethod void UpdateMarketingManagerwithConvertLead(){
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Region__c='',SMB_Sales_Cluster__c='');
        
       System.runAs(u){
          TestDataCreation.CreateMarketingManager(null);
          list<lead> ld=TestDataCreation.CreateLead();
          TestDataCreation.CreateQueue();
          Database.LeadConvert lc = new Database.LeadConvert();
           lc.setLeadId(ld[1].id);
            
           LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
           lc.setConvertedStatus(convertStatus.MasterLabel);
           lc.setDoNotCreateOpportunity(true);
            
           Database.LeadConvertResult lcr = Database.convertLead(lc);
           
            
       }
       
       
       }
       Public static testMethod void UpdateMarketingManagerwithConvertLeadwithcluster(){
       Profile p = [SELECT Id FROM Profile WHERE Name='Regional Administrator User SAMBA'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Region__c='',SMB_Sales_Cluster__c='NAM');
        
       System.runAs(u){
          TestDataCreation.CreateMarketingManager(u);
          list<lead> ld=TestDataCreation.CreateLead();
        //  TestDataCreation.CreateQueue();
          Database.LeadConvert lc = new Database.LeadConvert();
           lc.setLeadId(ld[1].id);
            
           LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
           lc.setConvertedStatus(convertStatus.MasterLabel);
           lc.setDoNotCreateOpportunity(true);
            
           Database.LeadConvertResult lcr = Database.convertLead(lc);
           
            
       }
       
       
       }
       
       Public static testMethod void UpdateMarketingManagerwithConvertLeadwithclusterandregion(){
       Profile p = [SELECT Id FROM Profile WHERE Name='Regional Administrator User SAMBA'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Region__c='APAC',SMB_Sales_Cluster__c='Amino');
        
       System.runAs(u){
          TestDataCreation.CreateMarketingManager(u);
          list<lead> ld=TestDataCreation.CreateLead();
          Database.LeadConvert lc = new Database.LeadConvert();
           lc.setLeadId(ld[1].id);
            
           LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
           lc.setConvertedStatus(convertStatus.MasterLabel);
           lc.setDoNotCreateOpportunity(true);
            
           Database.LeadConvertResult lcr = Database.convertLead(lc);
           
            
       }
       
       
       }
       
       Public static testMethod void UpdateMarketingManagerwithConvertLeadwithcluster_Region(){
       Profile p = [SELECT Id FROM Profile WHERE Name='Regional Administrator User SAMBA'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',SMB_Sales_Region__c='APAC',SMB_Sales_Cluster__c='');
        
       System.runAs(u){
          TestDataCreation.CreateMarketingManager(u);
          list<lead> ld=TestDataCreation.CreateLead();
          Database.LeadConvert lc = new Database.LeadConvert();
           lc.setLeadId(ld[1].id);
            
           LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
           lc.setConvertedStatus(convertStatus.MasterLabel);
           lc.setDoNotCreateOpportunity(true);
            
           Database.LeadConvertResult lcr = Database.convertLead(lc);
           
            
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
          lead ld= new Lead(); 
          insert ld;
          update ld;
          }
          Catch(DmlException e){
           System.assert(e.getMessage().contains(' First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing:'),e.getMessage());
           System.assertEquals('REQUIRED_FIELD_MISSING',e.getDmlStatusCode(0));


           
          }
        }
        }
   }