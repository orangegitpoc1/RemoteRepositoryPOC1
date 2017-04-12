@isTest

public class SMB_Permission_Set_Ctrl_Test{ 

SMB_Permission_Set_Ctrl objPermission=new SMB_Permission_Set_Ctrl ();
PermissionSetAssignment pPSA = new PermissionSetAssignment();
SMB_Permission_Set_Ctrl.DecoratedPSA  objPsa = new SMB_Permission_Set_Ctrl.DecoratedPSA(pPSA );

public static testMethod  void method1(){
       Id roleId=[select Id from UserRole limit 1].id;
       User u = TestDataCreation.createUsersWithUsernamePrefixAlias(1, 'System Administrator', '1', roleId, 'testpref1', 'tstal1')[0];
        
       System.runAs(u){
           SMB_Permission_Set_Ctrl ctrl=new SMB_Permission_Set_Ctrl();
           ctrl.getPermissionSetOptions();
           ctrl.getsearchUserToAdd();
           String psetlabel=[select id, label from PermissionSet limit 1][0].label;
           
           ctrl.labelToSearch=psetlabel;
           ctrl.labelToAdd=psetlabel;
           ctrl.assigneeToSearch='testpref1';
           ctrl.UserName =u.UserName;
           ctrl.UserId = u.id;
           ctrl.SearchPermissionSet();

           ctrl.labelToSearch=psetlabel;
           ctrl.labelToAdd=psetlabel;
           ctrl.assigneeToSearch='testpref1';
           ctrl.UserName =u.UserName;
           ctrl.UserId = u.id;
           ctrl.assignPSetToUser();

           ctrl.labelToSearch=psetlabel;
           ctrl.labelToAdd=psetlabel;
           ctrl.assigneeToSearch='testpref1';
           ctrl.UserName =u.UserName;
           ctrl.UserId = u.id;
           ctrl.SearchPermissionSet();

           ctrl.labelToSearch=psetlabel;
           ctrl.labelToAdd=psetlabel;
           ctrl.assigneeToSearch='testpref1';
           ctrl.UserName =u.UserName;
           ctrl.UserId = u.id;
         //  ctrl.listPSA[0].selected=true;  changes done by 161183 UST-1278
         //  ctrl.RemoveAssignements();  changes done by 161183    UST-1278
       }
   
}
}