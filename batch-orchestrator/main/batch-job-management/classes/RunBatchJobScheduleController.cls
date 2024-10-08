/**
 * This class is part of the sfdx-batch-orchestrator package, released under the MIT license.
 *
 * @description       : Apex Controller responsible for scheduling an entire Schedule ad-hoc.
 * @author            : dschibster
 * @group             : Batch Job Management
 * @last modified on  : 2021-08-27
 * @last modified by  : dschibster
 **/

public with sharing class RunBatchJobScheduleController {
    Batch_Job_Schedule__c scheduleRecord;

    public RunBatchJobScheduleController(ApexPages.StandardController stdCtrl) {
        scheduleRecord = (Batch_Job_Schedule__c) stdCtrl.getRecord();
    }

    public PageReference runSchedule() {
        BatchOrchestrator.runBatchSchedule(scheduleRecord.Id);
        PageReference ref = new PageReference('/' + scheduleRecord.Id);
        ref.setRedirect(true);
        return ref;
    }
}
