%Stop Signal Task


KbName('UnifyKeyNames');
%a session
rslt=struct('id',{},'sstf',{},'kp',{},'crans',{},'rt',{});
i=0;
str='';
stpbp=0;
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
while i<3
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
        rslt(i).crans=0;
    else
        points=[x0+50,y0;x0,y0+30;x0,y0-30];
        Screen('FillPoly',wPtr,0,points);
        Screen('FillRect',wPtr,0,[x0-50,y0-20,x0,y0+20]);
        rslt(i).crans=1;
    end
    %allow show
    Screen('Flip',wPtr);
    %ListenChar(2);
    %j=KbName('j');    
    stpbp=(rand(1)>0.3);
    rslt(i).id=i;
    rslt(i).sstf=stpbp;
    str=strcat(str,sprintf('%d: StopSignal= %d',i,stpbp),':');
    %start time
    stt=GetSecs;
    %detecting keyboard
    while 1
        %time out
        if (GetSecs-stt)>3
            rslt(i).kp='-1';
            rslt(i).rt='-1';
            break
        end
        %get keyboard signal
        [kD,secs,kC]=KbCheck;
        %stop signal
        if stpbp
            if (GetSecs-stt)>0.3
            stpbp=0;
            Beeper(2000,1,0.5);
            end
        end
        if kD
            rslt(i).kp=(char(KbName(kC)));
            rslt(i).rt=sprintf('%10.2f',(secs-stt));
            str=strcat(str,(char(KbName(kC))),',',sprintf('%10.2f',secs),' RT= ',sprintf('%10.2f',(secs-stt)),'|');
            break;         
        end
    end
    %ListenChar(0);
end
fids=fopen([pwd '\sstdata.txt'],'a');
fprintf(fids,'%s\r\n',str);
WriteStructsToText([pwd '\sstdata.txt'],rslt);
clmhd={'id','sstf','kp','crans','rt'};
% temp=rot90(struct2cell(rslt));
xlswrt=vertcat(clmhd,rot90(struct2cell(rslt)));
xlswrite([pwd '\sstdata.xls'],xlswrt);
% for j=1 : i
%   fprintf(fids,'%s',rslt(j));  
% end
% fwrite(fids,str);
fclose(fids);
fclose('all');
sca
