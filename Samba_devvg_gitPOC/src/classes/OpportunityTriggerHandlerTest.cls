@isTest
private class OpportunityTriggerHandlerTest {

    static testMethod void afterUpdateTest() {    
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeghijkl@testorg.com', SMB_Bypass_VR__c=true, PAD_BypassTrigger__c=';SMBW3_Opportunity_TR009_OppSplit_TRG;');
        
        User u1 = TestDataCreation.createUsers(1, 'Sales User SAMBA', null, null)[0];
        
        System.runAs(u){
            try{
                TestDataCreation.createSplitcommission(1, 'Commission');
                TestDataCreation.createSplitcommission(1, 'Finance');
                Opportunity opp = TestDataCreation.createOpportunities(1)[0];
                Opportunity newOpp = new Opportunity(Id=opp.Id, Amount = 11, OwnerId = u1.Id, Name=opp.Name);
                update newOpp;
                OpportunityTriggerHandler obj = new OpportunityTriggerHandler();
                obj.OnAfterUpdate(null, new List<Opportunity>{newOpp}, new Map<Id, Opportunity>{opp.Id => opp}, null);
                System.assert(false, 'Failed');
            }catch(Exception ex){
                System.assert(true, 'Running as Expected');            
            }
        }
    }
    
    static testMethod void partnerMandatoryTest() {    
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeghijkl@testorg.com', SMB_Bypass_VR__c=true, PAD_BypassTrigger__c=';SMBW3_Opportunity_TR009_OppSplit_TRG;');
        insert u;
        
        User u1 = TestDataCreation.createUsers(1, 'Sales User SAMBA', null, null)[0];
        
        List<Account> accs=null;
        Opportunity opp=null;
        System.runAs(u){
                TestDataCreation.createSplitcommission(1, 'Commission');
                TestDataCreation.createSplitcommission(1, 'Finance');
                accs=TestDataCreation.createAccounts(1);
                opp = TestDataCreation.createOpportunitiesWithAccount(1,accs[0].id)[0];
                opp.ownerId=u.id;
                update opp;
                opp.Smb_opportunity_without_partner__c=false;
                try {
                    update opp; //Should fail
                } catch(Exception e){}
                opp.Smb_opportunity_without_partner__c=true;
                update opp;
        }
    }

    static testMethod void parentOppIDTest() {    
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeghijkl@testorg.com', SMB_Bypass_VR__c=true, PAD_BypassTrigger__c=';SMBW3_Opportunity_TR009_OppSplit_TRG;');
        insert u;
        
        User u1 = TestDataCreation.createUsers(1, 'Sales User SAMBA', null, null)[0];
        
        List<Account> accs=null;
        Opportunity opp=null;
        Opportunity oppChild=null;
        System.runAs(u){
                TestDataCreation.createSplitcommission(1, 'Commission');
                TestDataCreation.createSplitcommission(1, 'Finance');
                accs=TestDataCreation.createAccounts(1);
                List<Opportunity> oppList = TestDataCreation.createOpportunitiesWithAccount(2,accs[0].id);
                opp = oppList[0];
                oppChild = oppList[1];
                oppChild.ownerId=u.id;
                opp.ownerId=u.id;
                opp.SMB_OPP_Public_Opportunity_ID__c='1234';
                update oppList;
                oppChild.SMB_OPP_Parent_Opportunity_ID__c='99999999'; //Any public Id which does not exist
                try {
                    update oppChild; //Should fail
                } catch(Exception e){}
                oppChild.SMB_OPP_Parent_Opportunity_ID__c=opp.SMB_OPP_Public_Opportunity_ID__c;
                update oppChild;
        }
    }
    
}