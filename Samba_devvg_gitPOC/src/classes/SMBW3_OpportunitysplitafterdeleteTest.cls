@isTest
public class SMBW3_OpportunitysplitafterdeleteTest { 
static testMethod void testsplitafterdelete()
    {
       TestDataCreation.createSplitcommission(1, 'Commission');
       TestDataCreation.createSplitsales(1, 'Sales User SAMBA');
       TestDataCreation.createSplitfinance(1, 'Finance');
       account acc=TestDataCreation.createAccounts(1)[0];
       System.assertEquals(acc.name,'Test0');
       account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
       opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0];
       string oppownerid=[select ownerid from opportunity where id=:opp.id].ownerid; 
       system.debug('opp1'+oppownerid);
       list<OpportunitySplit> oppSplit = TestDataCreation.createOppSplitcommission(2, opp.id);
       system.assertEquals(oppSplit.size(),2);
       // OpportunitySplit oppSplitcomm = TestDataCreation.createOppSplitcommission(1, opp.id)[0];
       list<OpportunitySplit> oppSplitfin = TestDataCreation.createOppSplitfinance(3, opp.id);
  List<OpportunitySplit> oppSplitList= [select id,opportunityid,SplitOwnerId from opportunitysplit where opportunityid =:opp.id and SplitOwnerId!=:oppownerid];
  system.debug('oppSplitList'+oppSplitList);
  delete oppSplitList[1];

 }

}