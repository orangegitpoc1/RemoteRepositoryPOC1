/**************************************************************
Created By:162487
Ust-1335
Cretaed on :2/8/2016
Test Class for SMB_Count_NO_of_Partner_Opportunity
*************************************************************/
@isTest(SeeAllData=true)
Private class SMB_Count_NO_of_Partner_Opportunity_Test{
    Private static testMethod void Insert_OpportunityithPartner(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeghijkl@testorg.com', SMB_Bypass_VR__c=true,SMB_Bypass_WF__c=true, PAD_BypassTrigger__c=';SMBW3_Opportunity_TR009_OppSplit_TRG;SMBW1_User_TR007_AddToGroup_TRG;SMBW1_Opportunity_TR002_SendEmail_TRG;');
        System.runAs(u){
        Test.startTest();
        OpportunityPartner Op=[select id,OpportunityId from opportunitypartner Limit 1] ;
        system.assert(op!=null);
        Opportunity opp=[select id,Partner_Is_available__c,Smb_opportunity_without_partner__c from Opportunity where id=:Op.OpportunityId];
        Opp.Partner_Is_available__c=false;
        
        update Opp;
        string opid=opp.id;
        system.assert(opp!=null);
        SMB_Count_NO_of_Partner_Opportunity SMNP = new SMB_Count_NO_of_Partner_Opportunity('SELECT id,Partner_Is_available__c,Smb_opportunity_without_partner__c,SMB_OPP_stage_Gam_nb__c FROM Opportunity where id=\'' + opid+'\'');
        Database.executeBatch(SMNP);  
         
        Test.stopTest();
        }   
    
    } 
    Private static testMethod void Insert_OpportunityithPartnerwithout_partner(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeghijkl@testorg.com', SMB_Bypass_VR__c=true,SMB_Bypass_WF__c=true, PAD_BypassTrigger__c=';SMBW3_Opportunity_TR009_OppSplit_TRG;SMBW1_User_TR007_AddToGroup_TRG;SMBW1_Opportunity_TR002_SendEmail_TRG;');
        System.runAs(u){
        Test.startTest();
             Opportunity op=[select id,Partner_Is_available__c,Smb_opportunity_without_partner__c from Opportunity limit 1];
             string opid=op.id;
             system.assert(op!=null);
             SMB_Count_NO_of_Partner_Opportunity SMNP = new SMB_Count_NO_of_Partner_Opportunity('SELECT id,Partner_Is_available__c,Smb_opportunity_without_partner__c,SMB_OPP_stage_Gam_nb__c FROM Opportunity where id=\'' + opid+'\'');
             Database.executeBatch(SMNP);  
         
        Test.stopTest();
        }
    
    
    }

}