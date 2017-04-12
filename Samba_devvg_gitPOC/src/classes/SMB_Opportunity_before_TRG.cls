public class SMB_Opportunity_before_TRG{
     //UST-01317
      //****************Update Stage 3 date when opportunity move from stage 2 and above and make it null when move 3 and less *************
    public static void updateStage3(List<opportunity> newlistOpp,Map<id,Opportunity> oldMapOpp){
        for(Opportunity Opp:newlistOpp){
        
              /*
              NO of stage value in opportunity 
               Pre_Qualification, 1, 
                Qualification, 2, 
                Proposal, 3, 
                Negociation, 4, 
                Handover, 5, 
               Closed_Won, 6, 
               Closed Lost, 7, 
               Closed Duplicate, 8, 
               Closed Cancelled, 9
               
               */
               //*********when previous stage is less than 3 and now selected 3 or greater than 3 but less than 8 then value of Stage_3_Entry_Date__c=null*********
                 if(opp.SMB_OPP_stage_Gam_nb__c>=3 && opp.SMB_OPP_stage_Gam_nb__c<8 && oldMapOpp.get(opp.id).SMB_OPP_stage_Gam_nb__c<3 ){
                     opp.Stage_3_Entry_Date__c=system.today();
                 }
              // ************when previous stage is greater than 3 less than 8 now select less than 3 ,value of Stage_3_Entry_Date__c=null*******
                 else if(opp.SMB_OPP_stage_Gam_nb__c<3&&oldMapOpp.get(opp.id).SMB_OPP_stage_Gam_nb__c>=3&&oldMapOpp.get(opp.id).SMB_OPP_stage_Gam_nb__c<9){
                     opp.Stage_3_Entry_Date__c=null;
                 }
             //**********when previous stage is less than or equal to 9 now selected stage greater than 3 and less than 8,then Stage_3_Entry_Date__c =today******
                 else if(opp.SMB_OPP_stage_Gam_nb__c>=3&&(oldMapOpp.get(opp.id).SMB_OPP_stage_Gam_nb__c==9 ||oldMapOpp.get(opp.id).SMB_OPP_stage_Gam_nb__c==8) &&opp.SMB_OPP_stage_Gam_nb__c<8 ){
                     opp.Stage_3_Entry_Date__c=system.today();
                 }
            }
    }
    
    //end of UST-01317
}