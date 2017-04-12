public without sharing class SMBW1_Opportunity_TR008_DefaultOrder_TRG {
// [15/01/20] OLE, Fixing SOQL to filter on 'Overlay' rather than 'Orders' since split name has been changed (see WIT-002038)
// [15/03/11] OLE W2.1 UST-01077/WIT-002044 temporary split simplification. Guess what? Changing again the name :-D

    public static void CreateDefaultOrder(List<Opportunity> listOpp){
        // Fixed OLE 15/01/20
        //List<OpportunitySplitType> listOST = [SELECT DeveloperName,Id,IsActive,MasterLabel FROM OpportunitySplitType
        //WHERE IsActive = True AND MasterLabel =: 'Orders' limit 1];
        List<OpportunitySplitType> listOSTgmt = [SELECT DeveloperName,Id,IsActive,MasterLabel FROM OpportunitySplitType
        WHERE IsActive = True AND MasterLabel ='Finance' limit 1];
        
        // Fix OLE 15/03/11
        List<OpportunitySplitType> listOST = [SELECT DeveloperName,Id,IsActive,MasterLabel FROM OpportunitySplitType
        WHERE IsActive = True AND MasterLabel ='Commission' limit 1];
        system.debug('vvvvvvvvvvvvv'+listOpp);
        List<OpportunitySplit> listOS = new List<OpportunitySplit>();
        system.debug('ggggggggggggg'+listOpp.size());
        for(Opportunity o : listOpp){
            system.debug('bbbbbbbbbbbbbbbbbbbbbbbb');
            OpportunitySplit os = new OpportunitySplit(SplitTypeId = listOSTgmt[0].Id, SplitPercentage = 100, Finance_Percent__c=100,
            OpportunityId = o.Id, SplitOwnerId = o.OwnerId,Finance_Amount__c=o.amount);
            OpportunitySplit osc = new OpportunitySplit(SplitTypeId = listOST[0].Id, SplitPercentage = 100,CommissionPercent__c=100,
            OpportunityId = o.Id, SplitOwnerId = o.OwnerId,Commission_Amount__c=o.Amount);
            listOS.add(osc);
             listOS.add(os);
            system.debug('ffffffffffffffffff'+listOS.size());
        }
       
          insert listOS;
        //  Database.insert(listOS, false);
    }
    public static void validatecommissionsplit(List<Opportunity> listOpp){
        Recordtype recordtypesimpleid=[SELECT DeveloperName,Id,Name,SobjectType FROM RecordType WHERE SobjectType = 'opportunity' and DeveloperName='Samba_DOA_Oppty'];
        map<id,profile> p=new map<id,profile>([select id,name from profile where name=:System.Label.Business_Developer_User_SAMBA or name=:System.Label.Sales_User_SAMBA ]);
        set<id>proid=p.keyset();
        set<id> oppid = new set<id>();
        Map<id,list<Opportunitysplit>> oppidsplit=new Map<id,list<Opportunitysplit>>();
            for(opportunity op:listOpp){
              oppid.add(op.id);
            }
        list<Opportunitysplit> oppsplit=[select id,OpportunityId,Split,Opportunity.id,SplitPercentage,SplitAmount,splitNote,
        SplitTypeId,SplitOwnerId,SplitOwner.firstname,SplitOwner.lastname,SplitOwner.name,Commission_Amount__c,CommissionPercent__c from OpportunitySplit where OpportunityId In :oppid
        and SplitTypeId=:Split__c.getValues('Commission').Split_id__c and CommissionPercent__c=null   ];
        system.debug('oppsplit'+oppsplit);
         system.debug('oppsplit'+oppsplit);
       if(oppsplit.size()>0){
       for(Opportunitysplit opsplit :oppsplit)    {
         if(oppidsplit.containsKey(opsplit.OpportunityId))
             {
             List<Opportunitysplit> splitId = oppidsplit.get(opsplit.OpportunityId);
             splitId.add(opsplit);
             oppidsplit.put(opsplit.OpportunityId,splitId);

             }
          else{
                  oppidsplit.put(opsplit.OpportunityId,new List<Opportunitysplit> {opsplit});
          
          }   
       } 
       }
       
       
       
       for(opportunity op:listOpp){
           system.debug('op.GAM_type__c'+op.GAM_type__c);
          // list<Opportunitysplit> osplit=oppidsplit.get(op.id);
               if(op.SMB_OPP_stage_nb__c>1 && op.recordtypeid!=recordtypesimpleid.id && oppidsplit.get(op.id)!=null && proid.contains(op.Owners_Profile__c) && op.Gam_Type__c=='Territory Model'  ){
                  op.addError(System.Label.Gam_Error_split);
                          
               }
               
               if(op.SMB_OPP_stage_nb__c>2 && op.recordtypeid==recordtypesimpleid.id && oppidsplit.get(op.id)!=null && proid.contains(op.Owners_Profile__c) && op.Gam_Type__c=='Territory Model'  ){
                  op.addError(System.Label.Gam_Error_split);
                          
               }
               
               if(op.SMB_OPP_stage_nb__c>4 && oppidsplit.get(op.id)!=null && proid.contains(op.Owners_Profile__c) && op.Gam_Type__c=='Standard Gam'  ){
                  op.addError(System.Label.Gam_Error_split);
                          
               }
               
               
    
    }
        
  }  
    
}