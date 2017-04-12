@isTest
public class SMBW3_TaskStageCategoryTriggerTest{
    
    static testMethod void testConditionOppStageDefaultAndNeg(){
        Profile p = [SELECT Id FROM Profile WHERE Name='sales user samba'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdef@testorg.com', SMB_Bypass_VR__c=true, SMB_SALES_CLUSTER__C='Russia' );
        System.runAs(u){
           TestDataCreation.createSplitcommission(1, 'Commission');
           account acc=TestDataCreation.createAccounts(1)[0];
           System.assertEquals(acc.name,'Test0');
           account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
           opportunity opp=TestDataCreation.createOpportunitiesWithAccountProposal(1,acc.id)[0]; 
            Task tsk = TestDataCreation.createTasks(1, opp.Id)[0];
            try {
                tsk.Category__c='Order Form';
                update tsk;
            } catch (Exception e){}

            try {
                tsk.Category__c='Order';
                update tsk;
            } catch (Exception e){}

                tsk.Category__c='Proposal';
                update tsk;
            
            opp.stageName='4 Negotiation';
            update opp;

            try {
                update tsk;
            } catch (Exception e){}
            
/*
            try {
                tsk.Category__c='ANYTHING ELSE';
                update tsk;
            } catch (Exception e){}
*/

        }
    }


    static testMethod void testConditionStageHandoverAndUSUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='sales user samba'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdef@testorg.com', SMB_Bypass_VR__c=true, SMB_SALES_CLUSTER__C='Russia' );
        System.runAs(u){
           TestDataCreation.createSplitcommission(1, 'Commission');
           account acc=TestDataCreation.createAccounts(1)[0];
           System.assertEquals(acc.name,'Test0');
           account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
           opportunity opp=TestDataCreation.createOpportunitiesWithAccountProposal(1,acc.id)[0]; 
            Task tsk = TestDataCreation.createTasks(1, opp.Id)[0];

                tsk.Category__c='Proposal';

            opp.stageName='5 Handover';
            update opp;

            try {
                update tsk;
            } catch (Exception e){}

/*
            try {
                tsk.Category__c='ANYTHING ELSE';
                update tsk;
            } catch (Exception e){}
*/
        }
    }

    static testMethod void testConditionPreQualAndNonRussiaUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='sales user samba'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdef@testorg.com', SMB_Bypass_VR__c=true, SMB_SALES_CLUSTER__C='Russia' );
        System.runAs(u){
           TestDataCreation.createSplitcommission(1, 'Commission');
           account acc=TestDataCreation.createAccounts(1)[0];
           System.assertEquals(acc.name,'Test0');
           account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
           opportunity opp=TestDataCreation.createOpportunitiesWithAccountProposal(1,acc.id)[0]; 
            Task tsk = TestDataCreation.createTasks(1, opp.Id)[0];

                tsk.Category__c='Proposal';

            try {
                opp.stageName='1 Pre-qualification';
                update opp;
                update tsk;
            } catch (Exception e){}
            
            u.SMB_SALES_CLUSTER__C='US';
            update u;

            try {
                tsk.Category__c='Proposal';
                update tsk;
            } catch (Exception e){}

        }
    }
    
}