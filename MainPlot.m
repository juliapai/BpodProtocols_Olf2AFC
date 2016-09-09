function MainPlot(AxesHandles, Action, varargin)
global nTrialsToShow %this is for convenience
global BpodSystem

switch Action
    case 'init'
        %% Outcome
        %initialize pokes plot
        nTrialsToShow = 90; %default number of trials to display
        
        if nargin >=3  %custom number of trials
            nTrialsToShow =varargin{1};
        end
        axes(AxesHandles.HandleOutcome);
        %         Xdata = 1:numel(SideList); Ydata = SideList(Xdata);
        %plot in specified axes
        BpodSystem.GUIHandles.OutcomePlot.Olf = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',8);
        BpodSystem.GUIHandles.OutcomePlot.Aud = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge',[.5,.5,.5],'MarkerFace',[.5,.5,.5], 'MarkerSize',8);
        BpodSystem.GUIHandles.OutcomePlot.DV = line(1:numel(BpodSystem.Data.Custom.DV),BpodSystem.Data.Custom.DV, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','b', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle = line(1,0, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross = line(1,0, 'LineStyle','none','Marker','+','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CumRwd = text(1,1,'0mL','verticalalignment','bottom','horizontalalignment','center');
        BpodSystem.GUIHandles.OutcomePlot.Correct = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.Incorrect = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.BrokeFix = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','b','MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.EarlyWithdrawal = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','none','MarkerFace','b', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.NoFeedback = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','none','MarkerFace','w', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.NoResponse = line(-1,[0 1], 'LineStyle','none','Marker','x','MarkerEdge','w','MarkerFace','none', 'MarkerSize',6);
        set(AxesHandles.HandleOutcome,'TickDir', 'out','XLim',[0, nTrialsToShow],'YLim', [-1.25, 1.25], 'YTick', [-1, 1],'YTickLabel', {'Right','Left'}, 'FontSize', 16);
        set(BpodSystem.GUIHandles.OutcomePlot.Olf,'xdata',find(~BpodSystem.Data.Custom.AuditoryTrial),'ydata',BpodSystem.Data.Custom.DV(~BpodSystem.Data.Custom.AuditoryTrial));
        set(BpodSystem.GUIHandles.OutcomePlot.Aud,'xdata',find(BpodSystem.Data.Custom.AuditoryTrial),'ydata',BpodSystem.Data.Custom.DV(BpodSystem.Data.Custom.AuditoryTrial));
        xlabel(AxesHandles.HandleOutcome, 'Trial#', 'FontSize', 18);
        hold(AxesHandles.HandleOutcome, 'on');
        %% Psyc Olfactory
        BpodSystem.GUIHandles.OutcomePlot.PsycOlf = line(AxesHandles.HandlePsycOlf,[5 95],[.5 .5], 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.PsycOlfFit = line(AxesHandles.HandlePsycOlf,[0 100],[.5 .5],'color','k');
        AxesHandles.HandlePsycOlf.YLim = [-.05 1.05];
        AxesHandles.HandlePsycOlf.XLim = 100*[-.05 1.05];
        AxesHandles.HandlePsycOlf.XLabel.String = '% odor A'; % FIGURE OUT UNIT
        AxesHandles.HandlePsycOlf.YLabel.String = '% left';
        AxesHandles.HandlePsycOlf.Title.String = 'Psychometric Olf';
        %% Psyc Auditory
        BpodSystem.GUIHandles.OutcomePlot.PsycAud = line(AxesHandles.HandlePsycAud,[-1 1],[.5 .5], 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.PsycAudFit = line(AxesHandles.HandlePsycAud,[-1. 1.],[.5 .5],'color','k');
        AxesHandles.HandlePsycAud.YLim = [-.05 1.05];
        AxesHandles.HandlePsycAud.XLim = [-1.05, 1.05];
        AxesHandles.HandlePsycAud.XLabel.String = 'beta'; % FIGURE OUT UNIT
        AxesHandles.HandlePsycAud.YLabel.String = '% left';
        AxesHandles.HandlePsycAud.Title.String = 'Psychometric Aud';
        %% Trial rate
        hold(AxesHandles.HandleTrialRate,'on')
        BpodSystem.GUIHandles.OutcomePlot.TrialRate = line(AxesHandles.HandleTrialRate,[0],[0], 'LineStyle','-','Color','k'); %#ok<NBRAK>
        AxesHandles.HandleTrialRate.XLabel.String = 'Time (min)'; % FIGURE OUT UNIT
        AxesHandles.HandleTrialRate.YLabel.String = 'nTrials';
        AxesHandles.HandleTrialRate.Title.String = 'Trial rate';
        %% Stimulus delay
        hold(AxesHandles.HandleFix,'on')
        AxesHandles.HandleFix.XLabel.String = 'Time (ms)';
        AxesHandles.HandleFix.YLabel.String = 'trial counts';
        AxesHandles.HandleFix.Title.String = 'Pre-stimulus delay';
        %% ST histogram
        hold(AxesHandles.HandleST,'on')
        AxesHandles.HandleST.XLabel.String = 'Time (ms)';
        AxesHandles.HandleST.YLabel.String = 'trial counts';
        AxesHandles.HandleST.Title.String = 'Odor sampling time';
        %% Feedback Delay histogram
        hold(AxesHandles.HandleFeedback,'on')
        AxesHandles.HandleFeedback.XLabel.String = 'Time (ms)';
        AxesHandles.HandleFeedback.YLabel.String = 'trial counts';
        AxesHandles.HandleFeedback.Title.String = 'Feedback delay';
    case 'update'
        %% Outcome
        iTrial = varargin{1};
        [mn, ~] = rescaleX(AxesHandles.HandleOutcome,iTrial,nTrialsToShow); % recompute xlim
        
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle, 'xdata', iTrial+1, 'ydata', 0);
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross, 'xdata', iTrial+1, 'ydata', 0);
        
        %plot modality background
        set(BpodSystem.GUIHandles.OutcomePlot.Olf,'xdata',find(~BpodSystem.Data.Custom.AuditoryTrial),'ydata',BpodSystem.Data.Custom.DV(~BpodSystem.Data.Custom.AuditoryTrial));
        set(BpodSystem.GUIHandles.OutcomePlot.Aud,'xdata',find(BpodSystem.Data.Custom.AuditoryTrial),'ydata',BpodSystem.Data.Custom.DV(BpodSystem.Data.Custom.AuditoryTrial));
        %plot past&future trials
        set(BpodSystem.GUIHandles.OutcomePlot.DV, 'xdata', mn:numel(BpodSystem.Data.Custom.DV), 'ydata',BpodSystem.Data.Custom.DV(mn:end));
        
        %Plot past trial outcomes
        indxToPlot = mn:iTrial;
        %Cumulative Reward Amount
        R = BpodSystem.Data.Custom.RewardMagnitude;
        ndxRwd = BpodSystem.Data.Custom.Rewarded;
        C = zeros(size(R)); C(BpodSystem.Data.Custom.ChoiceLeft==1&ndxRwd,1) = 1; C(BpodSystem.Data.Custom.ChoiceLeft==0&ndxRwd,2) = 1;
        R = R.*C;
        set(BpodSystem.GUIHandles.OutcomePlot.CumRwd, 'position', [iTrial+1 1], 'string', ...
            [num2str(sum(R(:))/1000) ' mL']);
        clear R C
        %Plot Rewarded
        ndxCor = BpodSystem.Data.Custom.ChoiceCorrect(indxToPlot)==1;
        Xdata = indxToPlot(ndxCor);
        Ydata = BpodSystem.Data.Custom.DV(indxToPlot); Ydata = Ydata(ndxCor);
        set(BpodSystem.GUIHandles.OutcomePlot.Correct, 'xdata', Xdata, 'ydata', Ydata);
        %Plot Incorrect
        ndxInc = BpodSystem.Data.Custom.ChoiceCorrect(indxToPlot)==0;
        Xdata = indxToPlot(ndxInc);
        Ydata = BpodSystem.Data.Custom.DV(indxToPlot); Ydata = Ydata(ndxInc);
        set(BpodSystem.GUIHandles.OutcomePlot.Incorrect, 'xdata', Xdata, 'ydata', Ydata);
        %Plot Broken Fixation
        ndxBroke = BpodSystem.Data.Custom.FixBroke(indxToPlot);
        Xdata = indxToPlot(ndxBroke); Ydata = zeros(1,sum(ndxBroke));
        set(BpodSystem.GUIHandles.OutcomePlot.BrokeFix, 'xdata', Xdata, 'ydata', Ydata);
        %Plot Early Withdrawal
        ndxEarly = BpodSystem.Data.Custom.EarlyWithdrawal(indxToPlot);
        Xdata = indxToPlot(ndxEarly);
        Ydata = zeros(1,sum(ndxEarly));
        set(BpodSystem.GUIHandles.OutcomePlot.EarlyWithdrawal, 'xdata', Xdata, 'ydata', Ydata);
        %Plot missed choice trials
        ndxMiss = isnan(BpodSystem.Data.Custom.ChoiceLeft(indxToPlot))&~ndxBroke&~ndxEarly;
        Xdata = indxToPlot(ndxMiss);
        Ydata = BpodSystem.Data.Custom.DV(indxToPlot); Ydata = Ydata(ndxMiss);
        set(BpodSystem.GUIHandles.OutcomePlot.NoResponse, 'xdata', Xdata, 'ydata', Ydata);
        %Plot NoFeedback trials
        ndxNoFeedback = ~BpodSystem.Data.Custom.Feedback(indxToPlot);
        Xdata = indxToPlot(ndxNoFeedback&~ndxMiss);
        Ydata = BpodSystem.Data.Custom.DV(indxToPlot); Ydata = Ydata(ndxNoFeedback&~ndxMiss);
        set(BpodSystem.GUIHandles.OutcomePlot.NoFeedback, 'xdata', Xdata, 'ydata', Ydata);
        %% Psyc Olf
        OdorFracA = BpodSystem.Data.Custom.OdorFracA(1:numel(BpodSystem.Data.Custom.ChoiceLeft));
        ndxOlf = ~BpodSystem.Data.Custom.AuditoryTrial(1:numel(BpodSystem.Data.Custom.ChoiceLeft));
        if isfield(BpodSystem.Data.Custom,'BlockNumber')
            BlockNumber = BpodSystem.Data.Custom.BlockNumber;
        else
            BlockNumber = ones(size(BpodSystem.Data.Custom.ChoiceLeft));
        end
        setBlocks = reshape(unique(BlockNumber),1,[]); % STOPPED HERE
        ndxNan = isnan(BpodSystem.Data.Custom.ChoiceLeft);
        for iBlock = setBlocks(end)
            ndxBlock = BpodSystem.Data.Custom.BlockNumber(1:numel(BpodSystem.Data.Custom.ChoiceLeft)) == iBlock;
            if any(ndxBlock)
                setStim = reshape(unique(OdorFracA(ndxBlock)),1,[]);
                psyc = nan(size(setStim));
                for iStim = setStim
                    ndxStim = reshape(OdorFracA == iStim,1,[]);
                    psyc(setStim==iStim) = sum(BpodSystem.Data.Custom.ChoiceLeft(ndxStim&~ndxNan&ndxBlock&ndxOlf))/...
                        sum(ndxStim&~ndxNan&ndxBlock&ndxOlf);
                end
                if iBlock <= numel(BpodSystem.GUIHandles.OutcomePlot.PsycOlf) && ishandle(BpodSystem.GUIHandles.OutcomePlot.PsycOlf(iBlock))
                    BpodSystem.GUIHandles.OutcomePlot.PsycOlf(iBlock).XData = setStim;
                    BpodSystem.GUIHandles.OutcomePlot.PsycOlf(iBlock).YData = psyc;
                    BpodSystem.GUIHandles.OutcomePlot.PsycOlfFit(iBlock).XData = linspace(min(setStim),max(setStim),100);
                    if sum(OdorFracA(ndxBlock&ndxOlf))>0
                        BpodSystem.GUIHandles.OutcomePlot.PsycOlfFit(iBlock).YData = glmval(glmfit(OdorFracA(ndxBlock&ndxOlf),...
                            BpodSystem.Data.Custom.ChoiceLeft(ndxBlock&ndxOlf)','binomial'),linspace(min(setStim),max(setStim),100),'logit');
                    end
                else
                    lineColor = rgb2hsv([0.8314    0.5098    0.4157]);
                    bias = tanh(.3 * BpodSystem.Data.Custom.RewardMagnitude(find(ndxBlock,1),:) * [1 -1]');
                    lineColor(1) = 0.08+0.04*bias; lineColor(2) = .75; lineColor(3) = abs(bias); lineColor = hsv2rgb(lineColor);
%                     lineColor = lineColor + [0 0.3843*(tanh(BpodSystem.Data.Custom.RewardMagnitude(find(ndxBlock,1),:) * [1 -1]')) 0]
                    BpodSystem.GUIHandles.OutcomePlot.PsycOlf(iBlock) = line(AxesHandles.HandlePsycOlf,setStim,psyc, 'LineStyle','none','Marker','o',...
                        'MarkerEdge',lineColor,'MarkerFace',lineColor, 'MarkerSize',6);
                    BpodSystem.GUIHandles.OutcomePlot.PsycOlfFit(iBlock) = line(AxesHandles.HandlePsycOlf,[0 100],[.5 .5],'color',lineColor);
                end
            end
            % GUIHandles.OutcomePlot.Psyc.YData = psyc;
        end
%         
%         
%         stimSet = unique(OdorFracA);
%         BpodSystem.GUIHandles.OutcomePlot.PsycOlf.XData = stimSet;
%         psyc = nan(size(stimSet));
%         for iStim = 1:numel(stimSet)
%             ndxStim = OdorFracA == stimSet(iStim);
%             ndxNan = isnan(BpodSystem.Data.Custom.ChoiceLeft(:));
%             psyc(iStim) = nansum(BpodSystem.Data.Custom.ChoiceLeft(ndxStim)/sum(ndxStim&~ndxNan));
%         end
%         BpodSystem.GUIHandles.OutcomePlot.PsycOlf.YData = psyc;

        %% Psych Aud
        AudDV = BpodSystem.Data.Custom.DV(1:numel(BpodSystem.Data.Custom.ChoiceLeft));
        ndxAud = BpodSystem.Data.Custom.AuditoryTrial(1:numel(BpodSystem.Data.Custom.ChoiceLeft));
        ndxNan = isnan(BpodSystem.Data.Custom.ChoiceLeft);
        AudBin = 8;
        BinIdx = discretize(AudDV,linspace(-1,1,AudBin+1));
        PsycY = grpstats(BpodSystem.Data.Custom.ChoiceLeft(ndxAud&~ndxNan),BinIdx(ndxAud&~ndxNan),'mean');
        PsycX = unique(BinIdx(ndxAud&~ndxNan))/AudBin*2-1-1/AudBin;
        BpodSystem.GUIHandles.OutcomePlot.PsycAud.YData = PsycY;
        BpodSystem.GUIHandles.OutcomePlot.PsycAud.XData = PsycX;
        if sum(ndxAud&~ndxNan) > 1
            BpodSystem.GUIHandles.OutcomePlot.PsycAudFit.XData = linspace(min(AudDV),max(AudDV),100);
            BpodSystem.GUIHandles.OutcomePlot.PsycAudFit.YData = glmval(glmfit(AudDV(ndxAud&~ndxNan),...
                BpodSystem.Data.Custom.ChoiceLeft(ndxAud&~ndxNan)','binomial'),linspace(min(AudDV),max(AudDV),100),'logit');
        end
        %% Trial rate
        BpodSystem.GUIHandles.OutcomePlot.TrialRate.XData = (BpodSystem.Data.TrialStartTimestamp-min(BpodSystem.Data.TrialStartTimestamp))/60;
        BpodSystem.GUIHandles.OutcomePlot.TrialRate.YData = 1:numel(BpodSystem.Data.Custom.ChoiceLeft);
        %% Stimulus delay
        cla(AxesHandles.HandleFix)
        BpodSystem.GUIHandles.OutcomePlot.HistBroke = histogram(AxesHandles.HandleFix,BpodSystem.Data.Custom.FixDur(BpodSystem.Data.Custom.FixBroke)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistBroke.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistBroke.EdgeColor = 'none';
        BpodSystem.GUIHandles.OutcomePlot.HistBroke.FaceColor = 'r';
        BpodSystem.GUIHandles.OutcomePlot.HistFix = histogram(AxesHandles.HandleFix,BpodSystem.Data.Custom.FixDur(~BpodSystem.Data.Custom.FixBroke)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistFix.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistFix.FaceColor = 'b';
        BpodSystem.GUIHandles.OutcomePlot.HistFix.EdgeColor = 'none';
        %% ST
        cla(AxesHandles.HandleST)
        BpodSystem.GUIHandles.OutcomePlot.HistSTbroke = histogram(AxesHandles.HandleST,BpodSystem.Data.Custom.ST*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistSTbroke.BinWidth = 50;
        %% Feedback delay
        cla(AxesHandles.HandleFeedback)
        BpodSystem.GUIHandles.OutcomePlot.HistNoFeed = histogram(AxesHandles.HandleFeedback,BpodSystem.Data.Custom.FeedbackTime(~BpodSystem.Data.Custom.Feedback)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.BinWidth = 100;
        BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.EdgeColor = 'none';
        BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.FaceColor = 'r';
        %BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.Normalization = 'probability';
        BpodSystem.GUIHandles.OutcomePlot.HistFeed = histogram(AxesHandles.HandleFeedback,BpodSystem.Data.Custom.FeedbackTime(BpodSystem.Data.Custom.Feedback)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistFeed.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistFeed.EdgeColor = 'none';
        BpodSystem.GUIHandles.OutcomePlot.HistFeed.FaceColor = 'b';
%         BpodSystem.GUIHandles.OutcomePlot.HistFeed.Normalization = 'probability';
end

end

function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end


