%Stop Signal Task
%2016-10-13
%By TanHY, Shanghai Mental Health Center
%Shanghai Jiao Tong University, China

KbName('UnifyKeyNames');
%a session
rslt=struct('id',{},'sstf',{},'kp',{},'crans',{},'anstf',{},'rt',{},'ssd',{});
i=0;
str='';
stptf=0;
tmpssd=0.2;
%anstf=0;
tmpans=' ';
%open window
scnsize = get(0,'MonitorPosition');
xW0=(scnsize(1)+scnsize(3))/2;
yW0=(scnsize(2)+scnsize(4))/2;
[wPtr,wRect]=Screen('OpenWindow',0,[255,255,255],[xW0-300,yW0-300,xW0+300,yW0+300]);
%introduction window
intropic=imread([pwd '\sstintro.png']);
Screen('PutImage',wPtr,intropic);
Screen('Flip',wPtr);
while 1
    [intropass]=KbCheck;
    if intropass
        break
    end
end
%set x0&y0
x0=(wRect(1)+wRect(3))/2;
y0=(wRect(2)+wRect(4))/2;
%a block

while i<5
    i=i+1;
    %fixtation
    Screen('DrawLine',wPtr,[0,0,0],x0-30,y0,x0+30,y0,5);
    Screen('DrawLine',wPtr,[0,0,0],x0,y0+30,x0,y0-30,5);
    Screen('Flip',wPtr);
    pause(0.5);
    %clear window
    Screen('FillRect',wPtr,255);
    Screen('Flip',wPtr);
    %left(0) or right(1)
    if rand(1)>0.5
        points=[x0-50,y0;x0,y0+30;x0,y0-30];
        Screen('FillPoly',wPtr,0,points);
        Screen('FillRect',wPtr,0,[x0,y0-20,x0+50,y0+20]);
        rslt(i).crans='left-F';
        tmpans='f';
    else
        points=[x0+50,y0;x0,y0+30;x0,y0-30];
        Screen('FillPoly',wPtr,0,points);
        Screen('FillRect',wPtr,0,[x0-50,y0-20,x0,y0+20]);
        rslt(i).crans='right-J';
        tmpans='j';
    end
    %allow show
    Screen('Flip',wPtr);
    %ListenChar(2);
    % stop signal prepare
    stptf=(rand(1)>0.3);
    if stptf
        [y, freq] = psychwavread([pwd '\tada.wav']);
        wavedata = y';
        nrchannels = size(wavedata,1);
        InitializePsychSound;
        pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
        PsychPortAudio('FillBuffer', pahandle, wavedata);
        plyaudio=1;
    end    
    %
    rslt(i).id=i;
    rslt(i).sstf=stptf;
    str=strcat(str,sprintf('%d: StopSignal= %d',i,stptf),':');
    %start time
    stt=GetSecs;
    %detecting keyboard    
    while 1  
        %time out
        if GetSecs-stt>3
            if stptf                
                rslt(i).ssd=tmpssd;
                if tmpssd<0.5
                    tmpssd=tmpssd+0.05;
                end
            end
            rslt(i).kp='-1';
            rslt(i).rt=-1;
            rslt(i).anstf=-1;
            break
        end
       % play stop signal audio
        if stptf
            if plyaudio
                if GetSecs-stt>tmpssd
                    t1 = PsychPortAudio('Start', pahandle, 1, 0, 1);
                    plyaudio=0;
                end
            end
        end                
        %get keyboard signal
        [kD,secs,kC]=KbCheck;            
        if kD
            kpchar=char(KbName(kC));
            rslt(i).kp=kpchar;
            rslt(i).rt=sprintf('%10.2f',(secs-stt));
            pause(1);
            if stptf
                PsychPortAudio('Stop', pahandle);
                rslt(i).ssd=tmpssd;
                if kpchar==tmpans
                    rslt(i).anstf=1;
                else
                    rslt(i).anstf=0;
                end 
                if tmpssd>0
                    tmpssd=tmpssd-0.05;
                end
            else
                if kpchar==tmpans
                    rslt(i).anstf=1;
                else
                    rslt(i).anstf=0;
                end 
                rslt(i).ssd=-1;
            end
            break;         
        end        
    end
    if stptf
        PsychPortAudio('Close', pahandle);
        stptf=0;
    end
    %ListenChar(0);
end
WriteStructsToText([pwd '\sstdata.txt'],rslt);
writetable(struct2table(rslt), 'sstdata.xls');
fclose('all');
sca
