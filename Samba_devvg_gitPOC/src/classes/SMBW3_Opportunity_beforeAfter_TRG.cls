public without sharing class SMBW3_Opportunity_beforeAfter_TRG{

public static void validateTotalpercentage(set<id> ids,list<Opportunity>oppty,list<opportunity> oldtrigger){
 Map<ID,decimal> mapsum=new map<ID,decimal>();
 Map<Id,list<OpportunitySplit>> Mapoppid_OpportunitySplit=new Map<Id,list<OpportunitySplit>>();
 Map<id,opportunity> oldopportunity=new Map<id,opportunity>();
 string commissionsplit;
 Recordtype recordtypesimpleid=([SELECT DeveloperName,Id,Name,SobjectType FROM RecordType WHERE SobjectType = 'opportunity' and DeveloperName='Samba_DOA_Oppty']);
 Map<id,profile> salesProfMap = new map<id,profile>([select id,name from profile where name=:System.Label.Sales_User_SAMBA  or name=:System.Label.Business_Developer_User_SAMBA]);
 Set<id> salesProfIds=salesProfMap.keyset();
    
    commissionsplit=Split__c.getValues('Commission').Split_id__c;
    for(opportunity oppt : oldtrigger){
     oldopportunity.put(oppt.id,oppt );
    }
    AggregateResult[] groupedResults=[select OpportunityId,SUM(CommissionPercent__c) sumc
    from OpportunitySplit where OpportunityId=:ids and SplitTypeId=:commissionsplit group by OpportunityId ];
    
    List<OpportunitySplit> commissionSplitwithAend=[select A_B_End__c,id,OpportunityId from OpportunitySplit where OpportunityId=:ids and SplitTypeId=:commissionsplit ];
    
    for(OpportunitySplit ops :commissionSplitwithAend){
          if(Mapoppid_OpportunitySplit.containsKey(ops.Opportunityid)){
                                    List<OpportunitySplit > opsplit = Mapoppid_OpportunitySplit.get(ops.Opportunityid);
                                     opsplit.add(ops);
                                     Mapoppid_OpportunitySplit.put(ops.Opportunityid,opsplit);
                        
                         }
                         else{
                                     Mapoppid_OpportunitySplit.put(ops.Opportunityid,new List<OpportunitySplit> {ops});
                                  
                         } 
       }   
    
    
    
    
    for (AggregateResult ar : groupedResults) {
        system.debug('ooooooooooooooooooooooooo'+ar);
         mapsum.put((ID)ar.get('OpportunityId'),(decimal)ar.get('sumc'));
    }
    system.debug('kkkkkkkkkkkkkk'+mapsum);
    
    for(Opportunity opp: oppty){
    system.debug('oldopportunity.get(opp.id)'+oldopportunity.get(opp.id));
    system.debug('oldopportunity.get(opp.id).stagename'+oldopportunity.get(opp.id).stagename);
    /*    if(opp.SMB_OPP_stage_nb__c>=1 && opp.recordtypeid!=recordtypesimpleid.id &&opp.stagename!=oldopportunity.get(opp.id).stagename && (mapsum.get(opp.id)<100 || mapsum.get(opp.id)==null )){
            opp.addError(System.Label.Gam_Commission_Error);
         
        }
        
       if(opp.SMB_OPP_stage_nb__c>=2 && opp.recordtypeid==recordtypesimpleid.id &&opp.stagename!=oldopportunity.get(opp.id).stagename && (mapsum.get(opp.id)<100 || mapsum.get(opp.id)==null ) ){
            opp.addError(System.Label.Gam_Commission_Error);
         
        }
      */
     
        if(opp.Stagename!='Closed Duplicate' && opp.Stagename!='Closed Cancelled' )
              {  
                 //Ust-1277 -new gam changes
                   if(mapsum.get(opp.id)<100){
                         opp.addError(System.Label.Gam_Commission_Error);
      
                    } //end of ust 1277 
                   system.debug('opp.Stagename'+opp.Stagename);
                    if(opp.SMB_OPP_stage_nb__c>1 && opp.recordtypeid!=recordtypesimpleid.id && (!salesProfIds.contains(opp.Owners_Profile__c)) && oldopportunity.get(opp.Id)!=null )
                        {
                           
                            opp.addError(System.label.Gam_before_update);
                                              
                        }
                      if(opp.SMB_OPP_stage_nb__c>2 && opp.recordtypeid==recordtypesimpleid.id && (!salesProfIds.contains(opp.Owners_Profile__c))&& oldopportunity.get(opp.Id)!=null  )              
                       
                       {
                             opp.addError(system.label.Gam_before_update);
                       }
                     //Ust-1277 -new gam changes      
              for(OpportunitySplit Os:Mapoppid_OpportunitySplit.get(opp.id)){
                  system.debug('Os'+Os);
                  system.debug('Os.A_B_End__c'+Os.A_B_End__c);
                  if(Os.A_B_End__c==null||Os.A_B_End__c=='--None--'){
                         Opp.addError(System.label.SMB_A_B_End_Opp);
                  }
                              
              } 
              //end ust -1277 
                      
            } 
             
    }
    
    


}

 public static void onchangeofAmount(set<id> ids,list<Opportunity>oppty) { 
          string Financesplit;
          string commissionsplit;
          Map<id,list<opportunitysplit>> oppfinancesplit=new map<id,list<opportunitysplit>>();
          Map<id,list<opportunitysplit>> oppCommissionsplit=new map<id,list<opportunitysplit>>();
          List<opportunitysplit> opscommission = new List<opportunitysplit>();
           List<opportunitysplit> opsFinance = new List<opportunitysplit>();
          Financesplit=Split__c.getValues('Finance').Split_id__c;
          commissionsplit=Split__c.getValues('Commission').Split_id__c;
          
                 if(ids.size()>0) {
                 list<Opportunitysplit> osFinance=[select id, OpportunityId,Opportunity.amount,Finance_Amount__c,Finance_Percent__c,Opportunity.id,Split,
                 SplitPercentage,SplitAmount,splitNote,SplitTypeId,SplitOwnerId,SplitOwner.firstname,SplitOwner.lastname,
                 SplitOwner.name from OpportunitySplit where OpportunityId=:ids and SplitTypeId=:Financesplit and Finance_Percent__c!=null];
                 
                 list<opportunitysplit> osCommision=[select id,OpportunityId,Split,Commission_Amount__c,CommissionPercent__c,Opportunity.id,
                 SplitPercentage,SplitAmount,splitNote,SplitTypeId,SplitOwnerId,SplitOwner.firstname,SplitOwner.lastname,SplitOwner.name from OpportunitySplit 
                 where OpportunityId=:ids and SplitTypeId=:commissionsplit and CommissionPercent__c!=null  ];
                 
                 for(Opportunitysplit osf:osFinance){
                 
                       if(oppfinancesplit.containsKey(osf.OpportunityId))
                     {
                     List<Opportunitysplit> splits = oppfinancesplit.get(osf.OpportunityId);
                     splits.add(osf);
                     oppfinancesplit.put(osf.OpportunityId,splits);
        
                     }
                  else{
                          oppfinancesplit.put(osf.OpportunityId,new List<Opportunitysplit> {osf});
                  
                  }  
                 
                 }
                 
                  for(Opportunitysplit osc:osCommision){
                 
                       if(oppCommissionsplit.containsKey(osc.OpportunityId))
                     {
                     List<Opportunitysplit> splitsc = oppCommissionsplit.get(osc.OpportunityId);
                     splitsc.add(osc);
                     oppCommissionsplit.put(osc.OpportunityId,splitsc);
        
                     }
                  else{
                          oppCommissionsplit.put(osc.OpportunityId,new List<Opportunitysplit> {osc});
                  
                  }  
                 
                 }
                 
                     for(opportunity op:oppty){
                      if(oppCommissionsplit.containsKey(op.Id)){
                         for(Opportunitysplit opst : oppCommissionsplit.get(op.id)){
                           opst.Commission_Amount__c=opst.CommissionPercent__c*op.amount*0.01;
                           opscommission.add(opst ); 
                           
                         
                         }
                        } 
                     
                     }
                     
                     for(opportunity op:oppty){
                      if(oppfinancesplit.containsKey(op.Id)){
                         for(Opportunitysplit opstf : oppfinancesplit.get(op.id)){
                           opstf.Finance_Amount__c=opstf.Finance_Percent__c*op.amount*0.01;
                           opsFinance.add(opstf); 
                           
                         
                         }
                         
                         }
                     
                     }
                     
                     If(opsFinance.size()>0){
                         try{
                           database.update(opsFinance,false);
                         }
                         catch(Exception e){
                                  for (Opportunitysplit opsplit: opsFinance) {
                                              opsplit.opportunityid.addError('There was a problem updating the  Finance split');
                                         }
                         
                         }
                     
                     }
                     
                      If(opscommission.size()>0){
                         try{
                            database.update(opscommission,false);
                         }
                         catch(Exception e){
                                 for (Opportunitysplit opsplit: opscommission) {
                                              opsplit.opportunityid.addError('There was a problem updating the Commission split');
                                         }
                         }
                     
                     }
            
                }
        }       
                        /*******************************    Added by Rajesh For OME Gam field**************************** */
      public static void updateOME_Gamfield(list<Opportunity>oppt) { 
          system.debug('oppt'+oppt);
         List<Opportunity> OpportunityList = new List<Opportunity>();
         Set<id> ids = new set<id>();
         Set<id> OwnersId = new set<id>();
            for(Opportunity oppty : oppt){ 
                    ids.add(oppty.id);
                    OwnersId.add(oppty.OwnerId); 
             } 
          system.debug('OwnersId'+OwnersId+ids);                   
          List<OpportunityContactRole> opptyContactWithGamRole=[SELECT contact.name, ContactId, Id, CreatedById, CreatedDate, IsDeleted, 
                                                                  LastModifiedById, LastModifiedDate,OpportunityId, IsPrimary, Role, SystemModstamp 
                                                                   FROM OpportunityContactRole WHERE  OpportunityId IN:Ids AND role like 'Partner GAM OME' ];
                //Opportunity.Account.RecordType.Name='Partner' AND
         Map<id, List<OpportunityContactRole>> opptyContactWithGamRoleMap=new Map<id, List<OpportunityContactRole>>();
         
         for (OpportunityContactRole contRole: opptyContactWithGamRole) {
             if(!opptyContactWithGamRoleMap.keySet().contains(contRole.OpportunityId)){
                 opptyContactWithGamRoleMap.put(contRole.OpportunityId, new List<OpportunityContactRole>{contRole});
             } else {
                 opptyContactWithGamRoleMap.get(contRole.OpportunityId).add(contRole);
             }
         }
         
         system.debug('opptyContactWithGamRole'+opptyContactWithGamRole);                                                          
                                                                   
          Map<id,User> MapUser=new Map<id,user>([SELECT name,UserRole.name from User WHERE (id IN:OwnersId and UserRoleID in (SELECT id FROM UserRole))]);
          system.debug('MapUser'+MapUser);
       // List<Recordtype>  currentAccountRecordtype=[SELECT id,name from Recordtype where id in (SELECT RecordTypeID FROM Account WHERE id=:oppty.AccountId)]  ;         
          for(Opportunity op : oppt){
       //   system.debug('MapUser.get(op.OwnerID).UserRole.name.contains'+MapUser.get(op.OwnerID).UserRole.name);
                  if(MapUser.size()>0 && MapUser.get(op.OwnerID).UserRole.name!=null ){ 
                  system.debug('MapUser'+MapUser); 
                  system.debug('opptyContactWithGamRole'+opptyContactWithGamRole);               
                          if(!(MapUser.get(op.OwnerID).UserRole.name.contains('OME'))){
                                op.OME_GAM__c=MapUser.get(op.OwnerID).name;
                                system.debug('11111111111111');
                          }
                         else {
                                 if(opptyContactWithGamRole.size()>0 && opptyContactWithGamRoleMap.get(op.id)!=null
                                     && opptyContactWithGamRoleMap.get(op.id).size()>0){ //k: Added "&& opptyContactWithGamRole.get(op.id)!=null"
                                      //op.OME_GAM__c=opptyContactWithGamRole.get(op.id).contact.name;
                                      op.OME_GAM__c=opptyContactWithGamRoleMap.get(op.id)[0].contact.name;
                                      system.debug('22222222222222222');
                                 
                                 }
                                 else
                                 {
                                     op.OME_GAM__c =MapUser.get(op.OwnerID).name;
                                      system.debug('33333333333333333333333');
                                 } 
                         }
                    }      
           }
       
       
    }   
      
      

}