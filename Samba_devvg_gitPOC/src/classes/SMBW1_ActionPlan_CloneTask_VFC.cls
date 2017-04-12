/*******************************************************
Created by J. Hazebrouck
Create a list of Tasks linked to an action plan from
an existing list of tasks
*******************************************************/
public without sharing class SMBW1_ActionPlan_CloneTask_VFC {
	
	private Id actionPlanId;
	public Action_Plan__c ac{get;set;}
	public Boolean allTasks{get;set;}
	public Boolean bool = false;
	public List<taskWrapper> listTaskWrapper{get;set;}
		
	public class taskWrapper {
		public Task taskRecord{get;set;}
		public Boolean bool{get;set;}
		
		public taskWrapper(Task t, Boolean b){
			taskRecord = t;
			bool = b;
		}
	}
	
	public SMBW1_ActionPlan_CloneTask_VFC(ApexPages.StandardController controller){
		this.actionPlanId=controller.getRecord().Id;
		ac = new Action_Plan__c();
		allTasks = false;
	}
	
	public pageReference retrieveTasks(){
		allTasks = true;
		listTaskWrapper = new List<taskWrapper>();
		if(ac.SMB_AP_TECH_Lookup_Id__c != null){
			for(Task t : [SELECT Id, WhoId, WhatId, OwnerId, Status, Subject, Category__c, ActivityDate, Description FROM Task WHERE WhatId =: ac.SMB_AP_TECH_Lookup_Id__c]){
				taskWrapper tw = new taskWrapper(t, false);
				listTaskWrapper.add(tw);
			}
		}
		return null;
	}
	
	public pageReference cloneTask(){
		List<Task> listTask = new List<Task>();
		List<Task> listTaskToInsert = new List<Task>();
		for(taskWrapper tw : listTaskWrapper){
			if(tw.bool){
				tw.taskRecord.WhatId = actionPlanId;
				tw.taskRecord.Description = '';
				listTask.add(tw.taskRecord);
			}
		}
		if(listTask.size() > 0){
			listTaskToInsert = listTask.deepClone(false, false, false);
			insert listTaskToInsert;
			PageReference pageRef = new PageReference('/' + actionPlanId + '?retURL=%2F' + actionPlanId);
	 		return pageRef;
		}
		else{
			Apexpages.addMessage( new Apexpages.Message(ApexPages.severity.Warning, System.Label.SMB_CL010_SelectTask));
			return null;
		}
	}
	
	public void newLine(){
		allTasks = true;
		listTaskWrapper.add(new taskWrapper(new Task(OwnerId = UserInfo.getUserId(), Status = 'Not Started'), false));
	}
	
	public pageReference cancel(){
		PageReference pageRef = new PageReference('/' + actionPlanId + '?retURL=%2F' + actionPlanId);
	 	return pageRef;
	}
}