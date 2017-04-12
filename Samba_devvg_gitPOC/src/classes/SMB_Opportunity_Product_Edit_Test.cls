@isTest(SeeAllData=true)
public class SMB_Opportunity_Product_Edit_Test {
static testmethod void constructorTest() {
  Profile pf = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = pf.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,SMB_Bypass_WF__c=true,PAD_BypassTrigger__c='',SMB_Sales_Cluster__c='');
  
   System.runAs(u){
 
     list<OpportunityLineItem> olil=[SELECT Id,ListPrice,Name FROM OpportunityLineItem];   
     System.Assert(olil.size()>0);
     Test.startTest();   
     Test.setCurrentPage(Page.SMB_Opportunity_Product_Edit_VFP);
     SMB_Opportunity_Product_Edit_VFC controller = new SMB_Opportunity_Product_Edit_VFC(new ApexPages.StandardController(olil[0]));
     controller.PageRedirect_opty();
     Test.stopTest();
        }
}
}