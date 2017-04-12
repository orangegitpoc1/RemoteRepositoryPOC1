@isTest(seeAllData=true)
public class SMB_CampaignMemberStatus_test{

    public testmethod static void insertCampaign(){
        list<CampaignStatus__c >listCampaignStatus=TestDataCreation.CreateCampaignStatus();
        list<campaign> campaignlist=TestDataCreation.CreateCampaign(); 
        
        for(campaign c:campaignlist){
         c.type='Email';
        }
        Update campaignlist;
        System.assertEquals(2,listCampaignStatus.size()); 
        System.assertEquals(2,campaignlist.size()); 
    
    }

}