global class SMB_BatchActionPlan_Scheduler implements Schedulable {
 String sch = '20 30 8 10 2 ?';
   global void execute(SchedulableContext sc) {
      SMB_BatchActionPlan_share b_share = new SMB_BatchActionPlan_share(); 
      database.executebatch(b_share,20);
   }
}