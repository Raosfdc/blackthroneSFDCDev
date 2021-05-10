import { LightningElement, track, api } from 'lwc';
import updateRecord from '@salesforce/apex/RecordFocusTimerCntrl.updateRecord';

export default class RecordFocusTimer extends LightningElement {

    @api recordId;
    @api objectApiName;
    @api timerFieldApiName;

    @track showStartBtn = true;
    @track timeVal = '0:0:0';
    timeIntervalInstance;
    totalMilliseconds = 0;
    @track timeBeforeUpdatingOnBlur = 0;

    start(event) {
        console.log('===start===>', this.objectApiName, '===>', this.recordId, '===>', this.timerFieldApiName);
        this.showStartBtn = false;
        var parentThis = this;

        // Run timer code in every 100 milliseconds
        this.timeIntervalInstance = setInterval(function() {
            // Time calculations for hours, minutes, seconds and milliseconds
            var hours = Math.floor((parentThis.totalMilliseconds % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            var minutes = Math.floor((parentThis.totalMilliseconds % (1000 * 60 * 60)) / (1000 * 60));
            var seconds = Math.floor((parentThis.totalMilliseconds % (1000 * 60)) / 1000);
            // var milliseconds = Math.floor((parentThis.totalMilliseconds % (1000)));
            
            // Output the result in the timeVal variable
            parentThis.timeVal = hours + ":" + minutes + ":" + seconds;// + ":" + milliseconds;   
            parentThis.totalMilliseconds += 100;
        }, 100);

        window.addEventListener("blur", function(event) {
            console.log('===BLUR CALLED===>', parentThis.objectApiName, '===>', parentThis.recordId, '===>', parentThis.timerFieldApiName, '===>', parentThis.timeVal, '===>', parentThis.timeBeforeUpdatingOnBlur);

            let currTimeVal = parentThis.timeVal;
            let lstTime = currTimeVal.split(':');
            console.log('===BLUR lstTime===>', lstTime);

            let totalTimeSpent = 0;
            let totalHr = 0;
            totalHr = lstTime[0] * 60;
            console.log('===BLUR totalHr===>', totalHr);

            let totalMin = 0;
            totalMin = lstTime[1] * 1;
            console.log('===BLUR totalMin===>', totalMin);

            let totalSec = 0;
            totalSec = lstTime[2] * 1;
            console.log('===BLUR totalSec===>', totalSec);

            totalTimeSpent = totalHr + totalMin + (totalSec > 30 ? 1 : 0);
            console.log('===BLUR totalTimeSpent 1===>', totalTimeSpent);

            totalTimeSpent = totalTimeSpent - parentThis.timeBeforeUpdatingOnBlur;
            console.log('===BLUR totalTimeSpent 2===>', totalTimeSpent);

            updateRecord({
                currentRecordId : parentThis.recordId,
                currentSobjectApiName : parentThis.objectApiName,
                timerFieldApiName : parentThis.timerFieldApiName,
                currentTimeSpent : totalTimeSpent
            })
            .then(result => {
                // Do nothing
                parentThis.timeBeforeUpdatingOnBlur += totalTimeSpent;
            })
            .catch(error => {
                console.log('-------error-------------'+error);
            });
        }, false);
    }

    stop(event) {
        console.log('===STOP CALLED===>', this.objectApiName, '===>', this.recordId, '===>', this.timerFieldApiName, '===>', this.timeVal);
        this.showStartBtn = true;

        let currTimeVal = this.timeVal;
        let lstTime = currTimeVal.split(':');
        console.log('===STOP lstTime===>', lstTime);
        
        let totalTimeSpent = 0;
        let totalHr = 0;
        totalHr = lstTime[0] * 60;
        console.log('===STOP totalHr===>', totalHr);

        let totalMin = 0;
        totalMin = lstTime[1] * 1;
        console.log('===STOP totalMin===>', totalMin);

        let totalSec = 0;
        totalSec = lstTime[2] * 1;
        console.log('===STOP totalSec===>', totalSec);

        totalTimeSpent = totalHr + totalMin + totalSec;
        console.log('===STOP totalTimeSpent===>', totalTimeSpent);

        updateRecord({
            currentRecordId : this.recordId,
            currentSobjectApiName : this.objectApiName,
            timerFieldApiName : this.timerFieldApiName,
            currentTimeSpent : totalTimeSpent
        })
        .then(result => {
            // Do nothing
        })
        .catch(error => {
            console.log('-------error-------------', error);
        });
        location.reload();
    }
}