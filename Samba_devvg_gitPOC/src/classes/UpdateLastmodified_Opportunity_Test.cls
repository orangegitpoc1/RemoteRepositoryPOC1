/* Created By 
use by Trigger UpdateOpportunityLastModified_Attachment,UpdateOpportunityLastModified_Note,
                UpdateOpportunity_Lastmodified_Event,UpdateOpportunity_Lastmodified_Task,class:UpdateLastmodified_Opportunity 
UST-01281/TKT-3229
*/
@isTest
private Class UpdateLastmodified_Opportunity_Test{
    static testMethod void UpdateLastmodified(){
        Profile p = [SELECT Id FROM Profile WHERE Name='sales user samba'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdef@testorg.com', SMB_Bypass_VR__c=true, SMB_SALES_CLUSTER__C='Russia',IT_Team__c=false);
        System.runAs(u){
        TestDataCreation.createSplitcommission(1, 'Commission');
        account acc=TestDataCreation.createAccounts(1)[0];
        System.assert(acc!=null);
        System.assertEquals(acc.name,'Test0');
        account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];         
        opportunity opp=TestDataCreation.createOpportunitiesWithAccountProposal(1,acc.id)[0]; 
        Task tsk = TestDataCreation.createTasks(1, opp.Id)[0];
        System.assert(tsk!=null);
        TestDataCreation.createNotes(1, opp.Id);
        TestDataCreation.createAttachments(1, opp.Id);
        Event e = new Event(OwnerId=u.id, Subject= 'call', WhatId =opp.Id,DurationInMinutes=10,ActivityDateTime=system.Today());  
        insert e;
        
        }       
    }
}