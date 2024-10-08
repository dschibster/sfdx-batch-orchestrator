/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Apex Controller responsible for Running a Single Apex Job from the Related List.
 * @author            : dschibster
 * @group             : Batch Job Management
 * @last modified on  : 2021-08-27
 * @last modified by  : dschibster
 **/

public with sharing class RunBatchApexJobController {
    Batch_Apex_Job__c jobRecord;

    public RunBatchApexJobController(ApexPages.StandardController stdCtrl) {
        if (!Test.isRunningTest()) {
            stdCtrl.addFields(
                new List<String>{ 'Batch_Class_Name__c', 'Batch_Job_Schedule__c', 'EnhancedLogging__c', 'Batch_Size__c', 'RecordType.DeveloperName' }
            );
        }
        jobRecord = (Batch_Apex_Job__c) stdCtrl.getRecord();
    }

    public PageReference runJob() {
        BatchOrchestrator.runBatchJob(jobRecord);
        PageReference ref = new PageReference('/' + jobRecord.Batch_Job_Schedule__c);
        ref.setRedirect(true);
        return ref;
    }
}
