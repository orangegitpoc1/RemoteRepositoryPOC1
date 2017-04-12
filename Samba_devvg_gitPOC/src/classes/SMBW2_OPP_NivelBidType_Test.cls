@isTest(SeeAllData=true)
private class SMBW2_OPP_NivelBidType_Test {

    static testMethod void myUnitTest(){
        Account a = new account(Name = 'JHAZTest', RCE_ID__c = '12345',SMB_No_Referential_ID_available__c=true); //, Sales_Region__c = 'France');
        insert a;
        
        Opportunity o = new Opportunity(Name = 'Test Oppty JHAZ', AccountId = a.Id, Amount = 10000000,
        StageName = '1 Pre-qualification', CloseDate = date.today().addDays(30));
        insert o;
        
        Test.startTest();
        Apexpages.currentPage().getParameters().put('oppId', o.Id);
        ApexPages.StandardController scTest = new ApexPages.standardController(o);
        SMBW2_OPP_NivelBidType_VFC aTest = new SMBW2_OPP_NivelBidType_VFC(scTest);
        aTest.cancel();
        aTest.oppty.SMB_Opp_Must_Win__c = 'No';
        aTest.getDomainValue();
        aTest.getICValue();
        aTest.getItemsDomainV();
        aTest.getItemsICV();
        aTest.getItemsOfferV();
        aTest.getItemsRussiaV();
        aTest.getItemsTCVV();
        aTest.getItemsWinV();
        aTest.getOfferValue();
        aTest.getRussiaValue();
        aTest.getTCVValue();
        aTest.getWinValue();
        aTest.saveBidType();
        aTest.setICValue('IC1');
        aTest.doNothingIC();
        aTest.saveBidType();
        aTest.setICValue('IC2');
        aTest.setWinValue('Win1');
        aTest.doNothingIC();
        aTest.saveBidType();
        aTest.setWinValue('Win2');
        aTest.setTCVValue('TCV4');
        aTest.doNothingIC();
        aTest.setTCVValue('TCV3');
        aTest.doNothingIC();
        aTest.setTCVValue('TCV2');
        aTest.setRussiaValue('Russia1');
        aTest.doNothingIC();
        aTest.setRussiaValue('Russia2');
        aTest.setDomainValue('Domain1');
        aTest.doNothingIC();
        aTest.setTCVValue('TCV1');
        aTest.setOfferValue('Offer1');
        aTest.doNothingIC();
        aTest.saveBidType();
        aTest.setOfferValue('Offer4');
        aTest.doNothingIC();
        aTest.saveBidType();
        Test.stopTest();
    }
}