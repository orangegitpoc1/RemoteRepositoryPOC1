@isTest
public class SMBW3_OptyLine_VFCETest {

    static testMethod void testSearchProductCondition1(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true, SMB_Bypass_WF__c=true, SMB_Sales_Region__c='Test Region');
        
        System.runAs(u){
            try{
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prd = TestDataCreation.createProduct(1, 'Test')[0];
            PriceBookEntry pbe = TestDataCreation.createPriceBookEntry(1, prd.Id, pricebookId)[0];
            TestDataCreation.createSplitcommission(1, 'Commission');
            Opportunity opp = TestDataCreation.createOpportunities(1)[0];
            //TestDataCreation.createOpportunityLineItem(1, opp.Id, 1, pbe.Id);
            TestDataCreation.createSettingRegion(1, 'Test Region');
            SMBW3_OptyLine_VFCE obj = new SMBW3_OptyLine_VFCE(new ApexPages.StandardController(opp));
            obj.SearchProduct();
            System.assert(true, 'Running as Expected');
            }catch(Exception ex){
            	System.assert(false, 'Failed');
            }
        }
        
    }
    
    static testMethod void testSearchProductCondition2(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true, SMB_Bypass_WF__c=true, SMB_Sales_Region__c='Test Region');
        
        System.runAs(u){
            try{
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prd = TestDataCreation.createProduct(1, 'Test')[0];
            PriceBookEntry pbe = TestDataCreation.createPriceBookEntry(1, prd.Id, pricebookId)[0];
            TestDataCreation.createSplitcommission(1, 'Commission');
            Opportunity opp = TestDataCreation.createOpportunitiesWithPriceBook(1, pricebookId)[0];
            //TestDataCreation.createOpportunityLineItem(1, opp.Id, 1, pbe.Id);
            TestDataCreation.createSettingRegion(1, 'Test Region');
            SMBW3_OptyLine_VFCE obj = new SMBW3_OptyLine_VFCE(new ApexPages.StandardController(opp));
            obj.oProduct2.domains__c = 'Test';
            obj.SearchProduct();
            System.assert(true, 'Running as Expected');
            }catch(Exception ex){
            	System.assert(false, 'Failed');
            }
        }
        
    }
    
    static testMethod void testgoToOptyDetail(){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true, SMB_Bypass_WF__c=true, SMB_Sales_Region__c='Test Region');
        
        System.runAs(u){
        	TestDataCreation.createSplitcommission(1, 'Commission');
            Opportunity opp = TestDataCreation.createOpportunities(1)[0];
            System.assertEquals('/'+opp.Id, new SMBW3_OptyLine_VFCE(new ApexPages.StandardController(opp)).goToOptyDetail().getUrl());
        }
    }
    
}