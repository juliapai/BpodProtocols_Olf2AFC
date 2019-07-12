function sma = stateMatrix(iTrial)
global BpodSystem
global TaskParameters

%% Define ports
LeftPort = floor(mod(TaskParameters.GUI.Ports_LMR/100,10));
CenterPort = floor(mod(TaskParameters.GUI.Ports_LMR/10,10));
RightPort = mod(TaskParameters.GUI.Ports_LMR,10);
LeftPortOut = strcat('Port',num2str(LeftPort),'Out');
CenterPortOut = strcat('Port',num2str(CenterPort),'Out');
RightPortOut = strcat('Port',num2str(RightPort),'Out');
LeftPortIn = strcat('Port',num2str(LeftPort),'In');
CenterPortIn = strcat('Port',num2str(CenterPort),'In');
RightPortIn = strcat('Port',num2str(RightPort),'In');

%reward ports and amount
LeftValve = 2^(LeftPort-1);
RightValve = 2^(RightPort-1);

LeftValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardMagnitude(iTrial,1), LeftPort);
RightValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardMagnitude(iTrial,2), RightPort);

%port LEDs
if TaskParameters.GUI.PortLEDs
    PortLEDs = 255;
else
    PortLEDs = 0;
end

if BpodSystem.Data.Custom.AuditoryTrial(iTrial) %auditory trial
    LeftRewarded = BpodSystem.Data.Custom.LeftRewarded(iTrial);
else %olfactory trial
    LeftRewarded = BpodSystem.Data.Custom.OdorID(iTrial) == 1;
end

if LeftRewarded == 1
    LeftPokeAction = 'rewarded_Lin_start';
    RightPokeAction = 'unrewarded_Rin_start';
elseif LeftRewarded == 0
    LeftPokeAction = 'unrewarded_Lin_start';
    RightPokeAction = 'rewarded_Rin_start';
else
    error('Bpod:Olf2AFC:unknownStim','Undefined stimulus');
end

if BpodSystem.Data.Custom.CatchTrial(iTrial)
    FeedbackDelayCorrect = 20;
else
    FeedbackDelayCorrect = TaskParameters.GUI.FeedbackDelay;
end
if TaskParameters.GUI.CatchError
    FeedbackDelayError = 20;
else
    FeedbackDelayError = TaskParameters.GUI.FeedbackDelay;
end

%Wire1 settings
%no video default
Wire1OutError = {};
Wire1OutCorrect =	{};
Wire1Out = {};
if TaskParameters.GUI.Wire1VideoTrigger % video
    Wire1OutError =	{'WireState', 1};
    switch TaskParameters.GUI.VideoTrials
        case 1 %only catch & error
            if BpodSystem.Data.Custom.CatchTrial(iTrial)
                Wire1OutCorrect =	{'WireState', 1};
            else
                Wire1OutCorrect =	{};
            end
        case 2 %all trials
            Wire1Out =	{'WireState', 1};
    end
end

%BNC2 settings -- assumes connection from Bpod BNC2 out to Trigger 2 of
%PulsePal to trigger PulsePal's output channel 3+4 connected to laser & recording
%system to switch laser on
%default: no laser, no BNC to high.
BNC2OutWT = 0;
BNC2OutST = 0;
BNC2OutPre = 0;
BNC2OutMT = 0;
BNC2OutReward = 0;
BNC2OutFB = 0;
BNC2OutITI = 0;
BNC2OutWaitC=0;
if  BpodSystem.Data.Custom.LaserTrial(iTrial) %laser trial. BNC2 to high (1 still low).
    if TaskParameters.GUI.LaserTimeInvestment
    BNC2OutWT = 2;%waiting time states
    end
    if TaskParameters.GUI.LaserStim
    BNC2OutST = 2;%stimulus time states
    end
    if TaskParameters.GUI.LaserPreStim
    BNC2OutPre = 2;%pre stimulus states
    end
    if TaskParameters.GUI.LaserMov
    BNC2OutMT = 2;%movement states
    end
    if TaskParameters.GUI.LaserRew
    BNC2OutReward = 2;%reward delivery
    end
    if TaskParameters.GUI.LaserFeedback
    BNC2OutFB = 2;%feedback states (delays)
    end
    if TaskParameters.GUI.LaserITI
    BNC2OutITI = 2; %iti (iti at end of trial)
    end
end

if  BpodSystem.Data.Custom.LaserTrial(max([1,iTrial-1]))%last trial was laser trial
    if TaskParameters.GUI.LaserITI
        BNC2OutWaitC = 2; %'iti' (pre center poke enter)
    end
end
    

%% Build state matrix
sma = NewStateMatrix();
sma = SetGlobalTimer(sma,1,FeedbackDelayCorrect);
sma = SetGlobalTimer(sma,2,FeedbackDelayError);
sma = AddState(sma, 'Name', 'wait_Cin_start',...
    'Timer', 0.05,...
    'StateChangeConditions', {'Tup','wait_Cin'},...
    'OutputActions', Wire1Out);
sma = AddState(sma, 'Name', 'wait_Cin',...
    'Timer', TaskParameters.GUI.CenterWaitMax,...
    'StateChangeConditions', {CenterPortIn, 'stay_Cin','Tup','ITI'},...
    'OutputActions', {'SoftCode',1,strcat('PWM',num2str(CenterPort)),PortLEDs,'BNCState',BNC2OutWaitC});
sma = AddState(sma, 'Name', 'broke_fixation',...
    'Timer',0,...
    'StateChangeConditions',{'Tup','timeOut_BrokeFixation'},...
    'OutputActions',{});
% sma = AddState(sma, 'Name', 'pre_odor_delivery',...
%     'Timer', 0.1,... % Time for odor to reach nostrils (Junya filtered these trials out offline)
%     'StateChangeConditions', {CenterPortOut,'ITI','Tup','odor_delivery'},...
%     'OutputActions', {'SoftCode',BpodSystem.Data.Custom.OdorPair(iTrial)});
if BpodSystem.Data.Custom.AuditoryTrial(iTrial)
    if BpodSystem.Data.Custom.ClickTask(iTrial)
        sma = AddState(sma, 'Name', 'stay_Cin',...
            'Timer', TaskParameters.GUI.StimDelay,...
            'StateChangeConditions', {CenterPortOut,'broke_fixation','Tup', 'stimulus_delivery_min'},...
            'OutputActions',{'BNCState',BNC2OutPre});
        sma = AddState(sma, 'Name', 'stimulus_delivery_min',...
            'Timer', TaskParameters.GUI.MinSampleAud,...
            'StateChangeConditions', {CenterPortOut,'early_withdrawal','Tup','stimulus_delivery'},...
            'OutputActions', {'BNCState',1+BNC2OutST});
        sma = AddState(sma, 'Name', 'early_withdrawal',...
            'Timer',0,...
            'StateChangeConditions',{'Tup','timeOut_EarlyWithdrawal'},...
            'OutputActions',{'BNCState',0});
        sma = AddState(sma, 'Name', 'stimulus_delivery',...
            'Timer', TaskParameters.GUI.AuditoryStimulusTime - TaskParameters.GUI.MinSampleAud,...
            'StateChangeConditions', {CenterPortOut,'wait_Sin_start','Tup','wait_Sin_start'},...
            'OutputActions', {'BNCState',1+BNC2OutST});
        sma=AddState(sma,'Name','wait_Sin_start',...
            'Timer',.5,...
            'StateChangeConditions', {'Tup','ITI','SoftCode2','wait_Sin'},...%listen back for softcode
            'OutputActions',{'SoftCode',31});
        sma = AddState(sma, 'Name', 'wait_Sin',...
            'Timer',TaskParameters.GUI.ChoiceDeadLine,...
            'StateChangeConditions', {LeftPortIn,'start_Lin',RightPortIn,'start_Rin','Tup','missed_choice'},...
            'OutputActions',{'BNCState',0+BNC2OutMT,strcat('PWM',num2str(LeftPort)),PortLEDs,strcat('PWM',num2str(RightPort)),PortLEDs});
    else %frequency task 
        sma = AddState(sma, 'Name', 'stay_Cin',...
            'Timer', TaskParameters.GUI.StimDelay,...
            'StateChangeConditions', {CenterPortOut,'broke_fixation','Tup', 'stimulus_delivery_trigger'},...
            'OutputActions',{'BNCState',BNC2OutPre});
        sma = AddState(sma, 'Name', 'stimulus_delivery_trigger',...
            'Timer', 0.1,...
            'StateChangeConditions', {CenterPortOut,'broke_fixation','Tup','No_Stim','BNC1High','stimulus_delivery_min'},...
            'OutputActions', {'SoftCode',21,'BNCState',BNC2OutST});%play stim
        sma = AddState(sma, 'Name', 'No_Stim',...
            'Timer', 0.01,...
            'StateChangeConditions', {'Tup','ITI'},...
            'OutputActions', {'SoftCode',22});%stop stim     
        sma = AddState(sma, 'Name', 'stimulus_delivery_min',...
            'Timer', TaskParameters.GUI.MinSampleAud,...
            'StateChangeConditions', {CenterPortOut,'early_withdrawal','Tup','stimulus_delivery'},...
            'OutputActions', {'BNCState',BNC2OutST});
        sma = AddState(sma, 'Name', 'early_withdrawal',...
            'Timer',0,...
            'StateChangeConditions',{'Tup','timeOut_EarlyWithdrawal'},...
            'OutputActions',{'SoftCode',22});%stop stim   
        sma = AddState(sma, 'Name', 'stimulus_delivery',...
            'Timer', TaskParameters.GUI.AuditoryStimulusTime - TaskParameters.GUI.MinSampleAud,...
            'StateChangeConditions', {CenterPortOut,'wait_Sin','Tup','wait_Sin'},...
            'OutputActions', {'BNCState',BNC2OutST});
        sma = AddState(sma, 'Name', 'wait_Sin',...
            'Timer',TaskParameters.GUI.ChoiceDeadLine,...
            'StateChangeConditions', {LeftPortIn,'start_Lin',RightPortIn,'start_Rin','Tup','missed_choice'},...
            'OutputActions',{'BNCState',BNC2OutMT,'SoftCode',22,strcat('PWM',num2str(LeftPort)),PortLEDs,strcat('PWM',num2str(RightPort)),PortLEDs});
    end
else
    sma = AddState(sma, 'Name', 'stay_Cin',...
        'Timer', TaskParameters.GUI.StimDelay,...
        'StateChangeConditions', {CenterPortOut,'broke_fixation','Tup', 'stimulus_delivery_min'},...
        'OutputActions',{'BNCState',BNC2OutPre});
    sma = AddState(sma, 'Name', 'stimulus_delivery_min',...
        'Timer', TaskParameters.GUI.OdorStimulusTimeMin,...
        'StateChangeConditions', {CenterPortOut,'early_withdrawal','Tup','stimulus_delivery'},...
        'OutputActions', {'BNCState',BNC2OutST,'SoftCode',BpodSystem.Data.Custom.OdorPair(iTrial)});
    sma = AddState(sma, 'Name', 'early_withdrawal',...
        'Timer',0,...
        'StateChangeConditions',{'Tup','timeOut_EarlyWithdrawal'},...
        'OutputActions',{});
    sma = AddState(sma, 'Name', 'stimulus_delivery',...
        'Timer', 0,...
        'StateChangeConditions', {CenterPortOut,'wait_Sin'},...
        'OutputActions', {'BNCState',BNC2OutST});
    sma = AddState(sma, 'Name', 'wait_Sin',...
        'Timer',TaskParameters.GUI.ChoiceDeadLine,...
        'StateChangeConditions', {LeftPortIn,'start_Lin',RightPortIn,'start_Rin','Tup','missed_choice'},...
        'OutputActions',{'BNCState',BNC2OutMT,'SoftCode',1,strcat('PWM',num2str(LeftPort)),PortLEDs,strcat('PWM',num2str(RightPort)),PortLEDs});
end
sma = AddState(sma, 'Name','start_Lin',...
    'Timer',0,...
    'StateChangeConditions', {'Tup','start_Lin2'},...
    'OutputActions',{'GlobalTimerTrig',1});%there are two start_Lin states to trigger each global timer separately (Bpod bug)
sma = AddState(sma, 'Name','start_Lin2',...
    'Timer',0,...
    'StateChangeConditions', {'Tup',LeftPokeAction},...
    'OutputActions',{'GlobalTimerTrig',2});
sma = AddState(sma, 'Name','start_Rin',...
    'Timer',0,...
    'StateChangeConditions', {'Tup','start_Rin2'},...
    'OutputActions',{'GlobalTimerTrig',1});%there are two start_Rin states to trigger each global timer separately (Bpod bug)
sma = AddState(sma, 'Name','start_Rin2',...
    'Timer',0,...
    'StateChangeConditions', {'Tup',RightPokeAction},...
    'OutputActions',{'GlobalTimerTrig',2});
sma = AddState(sma, 'Name', 'rewarded_Lin_start',...
    'Timer', 0.05,...
    'StateChangeConditions', {LeftPortOut,'rewarded_Lin_grace','Tup','rewarded_Lin'},...
    'OutputActions', [Wire1OutCorrect, {'BNCState',BNC2OutWT}]);
sma = AddState(sma, 'Name', 'rewarded_Lin',...
    'Timer', FeedbackDelayCorrect,...
    'StateChangeConditions', {LeftPortOut,'rewarded_Lin_grace','Tup','water_L','GlobalTimer1_End','water_L'},...
    'OutputActions', {'BNCState',BNC2OutWT});
sma = AddState(sma, 'Name', 'rewarded_Lin_grace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions',{'Tup','skipped_feedback',LeftPortIn,'rewarded_Lin','GlobalTimer1_End','skipped_feedback',CenterPortIn,'skipped_feedback',RightPortIn,'skipped_feedback'},...
    'OutputActions', {'BNCState',BNC2OutWT});
sma = AddState(sma, 'Name', 'rewarded_Rin_start',...
    'Timer', 0.05,...
    'StateChangeConditions', {RightPortOut,'rewarded_Rin_grace','Tup','rewarded_Rin'},...
    'OutputActions', [Wire1OutCorrect, {'BNCState',BNC2OutWT}]);
sma = AddState(sma, 'Name', 'rewarded_Rin',...
    'Timer', FeedbackDelayCorrect,...
    'StateChangeConditions', {RightPortOut,'rewarded_Rin_grace','Tup','water_R','GlobalTimer1_End','water_R'},...
    'OutputActions', {'BNCState',BNC2OutWT});
sma = AddState(sma, 'Name', 'rewarded_Rin_grace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions',{'Tup','skipped_feedback',RightPortIn,'rewarded_Rin','GlobalTimer1_End','skipped_feedback',CenterPortIn,'skipped_feedback',LeftPortIn,'skipped_feedback'},...
    'OutputActions', {'BNCState',BNC2OutWT});
sma = AddState(sma, 'Name', 'unrewarded_Lin_start',...
    'Timer', 0.05,...
    'StateChangeConditions', {LeftPortOut,'unrewarded_Lin_grace','Tup','unrewarded_Lin'},...
    'OutputActions', [Wire1OutError, {'BNCState',BNC2OutWT}]); 
sma = AddState(sma, 'Name', 'unrewarded_Lin',...
    'Timer', FeedbackDelayError,...
    'StateChangeConditions', {LeftPortOut,'unrewarded_Lin_grace','Tup','timeOut_IncorrectChoice','GlobalTimer2_End','timeOut_IncorrectChoice'},...
    'OutputActions', {'BNCState',BNC2OutWT}); 
sma = AddState(sma, 'Name', 'unrewarded_Lin_grace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions',{'Tup','skipped_feedback',LeftPortIn,'unrewarded_Lin','GlobalTimer2_End','skipped_feedback',CenterPortIn,'skipped_feedback',RightPortIn,'skipped_feedback'},...
    'OutputActions', {'BNCState',BNC2OutWT});
sma = AddState(sma, 'Name', 'unrewarded_Rin_start',...
    'Timer', 0.05,...
    'StateChangeConditions', {RightPortOut,'unrewarded_Rin_grace','Tup','unrewarded_Rin'},...
    'OutputActions', [Wire1OutError, {'BNCState',BNC2OutWT}]);
sma = AddState(sma, 'Name', 'unrewarded_Rin',...
    'Timer', FeedbackDelayError,...
    'StateChangeConditions', {RightPortOut,'unrewarded_Rin_grace','Tup','timeOut_IncorrectChoice','GlobalTimer2_End','timeOut_IncorrectChoice'},...
    'OutputActions', {'BNCState',BNC2OutWT});
sma = AddState(sma, 'Name', 'unrewarded_Rin_grace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions',{'Tup','skipped_feedback',RightPortIn,'unrewarded_Rin','GlobalTimer2_End','skipped_feedback',CenterPortIn,'skipped_feedback',LeftPortIn,'skipped_feedback'},...
    'OutputActions', {'BNCState',BNC2OutWT});
sma = AddState(sma, 'Name', 'water_L',...
    'Timer', LeftValveTime,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', {'ValveState', LeftValve,'BNCState',BNC2OutReward});
sma = AddState(sma, 'Name', 'water_R',...
    'Timer', RightValveTime,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', {'ValveState', RightValve,'BNCState',BNC2OutReward});
sma = AddState(sma, 'Name', 'timeOut_BrokeFixation',...
    'Timer',TaskParameters.GUI.TimeOutBrokeFixation,...
    'StateChangeConditions',{'Tup','ITI'},...
    'OutputActions',{'SoftCode',11,'BNCState',BNC2OutFB});
sma = AddState(sma, 'Name', 'timeOut_EarlyWithdrawal',...
    'Timer',TaskParameters.GUI.TimeOutEarlyWithdrawal,...
    'StateChangeConditions',{'Tup','ITI'},...
    'OutputActions',{'SoftCode',11,'BNCState',BNC2OutFB});
if  TaskParameters.GUI.IncorrectChoiceFeedbackType == 2 % IncorrectChoiceFeedbackType == Tone
    sma = AddState(sma, 'Name', 'timeOut_IncorrectChoice',...
        'Timer',TaskParameters.GUI.TimeOutIncorrectChoice,...
        'StateChangeConditions',{'Tup','ITI'},...
        'OutputActions',{'SoftCode',11,'BNCState',BNC2OutFB});
elseif  TaskParameters.GUI.IncorrectChoiceFeedbackType == 3 % IncorrectChoiceFeedbackType == PortLED
    sma = AddState(sma, 'Name', 'timeOut_IncorrectChoice',...
        'Timer',0.1,...
        'StateChangeConditions',{'Tup','timeOut_IncorrectChoice2'},...
        'OutputActions',{strcat('PWM',num2str(LeftPort)),PortLEDs,strcat('PWM',num2str(CenterPort)),PortLEDs,strcat('PWM',num2str(RightPort)),PortLEDs,'BNCState',BNC2OutFB});
    sma = AddState(sma, 'Name', 'timeOut_IncorrectChoice2',...
        'Timer',TaskParameters.GUI.TimeOutIncorrectChoice,... 
        'StateChangeConditions',{'Tup','ITI'},...
        'OutputActions',{'BNCState',BNC2OutFB});
else % IncorrectChoiceFeedbackType == None
    sma = AddState(sma, 'Name', 'timeOut_IncorrectChoice',...
        'Timer',TaskParameters.GUI.TimeOutIncorrectChoice,...
        'StateChangeConditions',{'Tup','ITI'},...
        'OutputActions',{'BNCState',BNC2OutFB});
end
if  TaskParameters.GUI.SkippedFeedbackFeedbackType == 2 % SkippedFeedbackFeedbackType == Tone
    sma = AddState(sma, 'Name', 'timeOut_SkippedFeedback',...
        'Timer',TaskParameters.GUI.TimeOutSkippedFeedback,...
        'StateChangeConditions',{'Tup','ITI'},...
        'OutputActions',{'SoftCode',12,'BNCState',BNC2OutFB});
elseif  TaskParameters.GUI.SkippedFeedbackFeedbackType == 3 % SkippedFeedbackFeedbackType == PortLED
    sma = AddState(sma, 'Name', 'timeOut_SkippedFeedback',...
        'Timer',0.1,...
        'StateChangeConditions',{'Tup','timeOut_SkippedFeedback2'},...
        'OutputActions',{strcat('PWM',num2str(LeftPort)),PortLEDs,strcat('PWM',num2str(CenterPort)),PortLEDs,strcat('PWM',num2str(RightPort)),PortLEDs,'BNCState',BNC2OutFB});
    sma = AddState(sma, 'Name', 'timeOut_SkippedFeedback2',...
        'Timer',TaskParameters.GUI.TimeOutSkippedFeedback,... 
        'StateChangeConditions',{'Tup','ITI'},...
        'OutputActions',{'BNCState',BNC2OutFB});
else % SkippedFeedbackFeedbackType == None
    sma = AddState(sma, 'Name', 'timeOut_SkippedFeedback',...
        'Timer',TaskParameters.GUI.TimeOutSkippedFeedback,...
        'StateChangeConditions',{'Tup','ITI'},...
        'OutputActions',{'BNCState',BNC2OutFB});
end
sma = AddState(sma, 'Name', 'skipped_feedback',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','timeOut_SkippedFeedback'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'missed_choice',...
    'Timer',0,...
    'StateChangeConditions',{'Tup','ITI'},...
    'OutputActions',{});
sma = AddState(sma, 'Name', 'ITI',...
    'Timer',max(TaskParameters.GUI.ITI,0.5),...
    'StateChangeConditions',{'Tup','exit'},...
    'OutputActions',{'SoftCode',9,'BNCState',BNC2OutITI}); % Sets flow rates for next trial
% sma = AddState(sma, 'Name', 'state_name',...
%     'Timer', 0,...
%     'StateChangeConditions', {},...
%     'OutputActions', {});
end
