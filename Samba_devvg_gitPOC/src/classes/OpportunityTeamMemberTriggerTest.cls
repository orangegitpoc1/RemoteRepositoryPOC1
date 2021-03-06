@isTest
private class OpportunityTeamMemberTriggerTest {

    static testMethod void afterInsertTest() {    
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeghijkl@testorg.com', SMB_Bypass_VR__c=true, PAD_BypassTrigger__c=';SMBW3_Opportunity_TR009_OppSplit_TRG;');
        System.runAs(u){
            try{
                TestDataCreation.createSplitcommission(1, 'Commission');
                Opportunity opp = TestDataCreation.createOpportunities(1)[0];
                TestDataCreation.createOpportunityTeamMember(1, opp.Id, u.Id);
                System.assert(true, 'Running as Expected');
            }catch(Exception ex){
                System.assert(false, 'Failed');
            }
            
        }
        
    }
    
    static testMethod void afterDeleteTest() {    
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeghijkl@testorg.com', SMB_Bypass_VR__c=true, PAD_BypassTrigger__c=';SMBW3_Opportunity_TR009_OppSplit_TRG;');
        Id currUser = UserInfo.getUserId();
        System.runAs(u){
            try{
                TestDataCreation.createSplitcommission(1, 'Commission');
                Opportunity opp = TestDataCreation.createOpportunities(1)[0];
                delete TestDataCreation.createOpportunityTeamMember(1, opp.Id, currUser);
                System.assert(true, 'Running as Expected');
            }catch(Exception ex){
                System.assert(false, 'Failed');
            }
        }
        
    }
}