@isTest
public class SMBW3_Opportunity_Spilit_Test{
    
    public static testMethod void insertsplit(){
       Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
       User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='');
        
       System.runAs(u){
       TestDataCreation.createSplitcommission(1, 'Commission');
       TestDataCreation.createSplitsales(1, 'Sales User SAMBA');
       TestDataCreation.createSplitfinance(1, 'Finance');
       account acc=TestDataCreation.createAccounts(1)[0];
       System.assertEquals(acc.name,'Test0');
       account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
       opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0]; 
       
       list<OpportunitySplit> oppSplit = TestDataCreation.createOppSplitcommission(2, opp.id);
       // OpportunitySplit oppSplitcomm = TestDataCreation.createOppSplitcommission(1, opp.id)[0];
       list<OpportunitySplit> oppSplitfin = TestDataCreation.createOppSplitfinance(3, opp.id);
       list<OpportunitySplit> oppSplitf= new list<OpportunitySplit>();
       list<OpportunitySplit> oppSplitc= new list<OpportunitySplit>();
       oppSplitf.addAll(oppSplitfin);
       oppSplitc.addAll(oppSplit );
       
       ApexPages.StandardController opp_edit = new ApexPages.StandardController(opp);
       PageReference pageRef = Page.SMBW3_Opportunity_Spilit_VFP;
       Test.setCurrentPage(pageRef);
       ApexPages.currentPage().getParameters().put('id', opp.id);
       
       SMBW3_Opportunity_Spilit_VFC testController = new SMBW3_Opportunity_Spilit_VFC(opp_edit );
       
       SMBW3_Opportunity_Spilit_VFC.oppsplitwrapper wrappersplit1= new SMBW3_Opportunity_Spilit_VFC.oppsplitwrapper(oppSplit[1] );
       SMBW3_Opportunity_Spilit_VFC.oppsplitwrapper wrappersplit2= new SMBW3_Opportunity_Spilit_VFC.oppsplitwrapper(oppSplitfin[1]);
       wrappersplit1.compareTo(wrappersplit1);
       testController.processLinkClick();
       testController.Edit_split();       
        
     }  
    
    }
}