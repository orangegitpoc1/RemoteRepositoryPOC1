public class OpportunitySplitTriggerHandler {
   
   public static void handleAfterDelete (List<OpportunitySplit> oldList  )
   {
         list<Opportunity> opp2 =new list<Opportunity>();
        set<Id> oppset =new set<Id> ();
        for(OpportunitySplit oppsplit :oldList)
        {
            oppset.add(oppsplit.opportunityid);
        }
         
        for(Opportunity opp:[SELECT Id, OwnerId, GAM_type__c,amount, (SELECT Id, SplitOwnerId,CommissionPercent__c,Commission_Amount__c FROM OpportunitySplits where splittype.MasterLabel IN ('Finance','Commission')) FROM Opportunity where id IN:oppSet and SMB_OPP_stage_Gam_nb__c < 6])
        {
              if(opp.OpportunitySplits.size() == 0)
            {
                opp2.add(opp);
            } 
        }
        SMBW1_Opportunity_TR008_DefaultOrder_TRG.CreateDefaultOrder(opp2); 
   }
   
   }