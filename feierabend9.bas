INCLUDE "GW.bas"
INCLUDE "GW_UTILS.bas"

! v7 -> v8:
! - added Break-Start-Stop
! - new transmission format incl. date
! - code clean up
! v8 -> v9:
! - page scaled to 70%

astart$=""
astop$=""
adur$=""
apause$=""
amail$=""
version$="9"

TEXT.OPEN R, FN2, "settings.txt"
if FN2<>-1 then
  TEXT.READLN FN2, astart$
  TEXT.READLN FN2, astop$
  TEXT.READLN FN2, adur$
  TEXT.READLN FN2, apause$
  TEXT.READLN FN2, amail$
  text.readln FN2, abstart$
  text.readln FN2, abstop$
  TEXT.CLOSE FN2
else
  TEXT.OPEN W, FN1, "settings.txt"
  TEXT.WRITELN FN1, "08:00"
  TEXT.WRITELN FN1, "16:30"
  TEXT.WRITELN FN1, "480"
  TEXT.WRITELN FN1, "30"
  TEXT.WRITELN FN1, "schurzmann@gmail.com"
  text.writeln FN1, "10:00"
  text.writeln FN1, "10:15"
  TEXT.CLOSE FN1
endif

GW_ZOOM_INPUT(1)
page = GW_NEW_PAGE()
GW_PAGE_SCALE(page, 0.7)

GW_ADD_TITLEBAR(page, "Call it a day "+version$)
GW_SHELF_OPEN(page)
tstart=gw_add_inputtime(page,"(A) Start time",astart$)
GW_SHELF_NEWCELL(page)
tstop=gw_add_inputtime(page,"(B) Stop time",astop$)
gw_shelf_newrow(page)
GW_ADD_BUTTON(page, "(3) set day's start = now", "button4_SetStart")
GW_SHELF_NEWCELL(page)
GW_ADD_BUTTON(page, "(4) set day's end = now", "button5_SetStop")
gw_shelf_newrow(page)
GW_ADD_BUTTON(page, "(1) Calculate stop time", "button1_CalcStop")
GW_SHELF_NEWCELL(page)
GW_ADD_BUTTON(page, "(2) Calculate start time", "button2_CalcStart")
gw_shelf_newrow(page)
twork=gw_add_inputline(page,"(C) Working time in minutes",adur$)
GW_SHELF_NEWCELL(page)
GW_ADD_BUTTON(page, "(5) Calculate work duration", "button3_CalcDur")
GW_SHELF_NEWrow(page)
gw_add_text(page,"(G) Break options")
R1 = GW_ADD_RADIO(page, 0, ">calculate break, result in (D)") 
R2 = GW_ADD_RADIO(page, R1, "set break = 0 min") 
R3 = GW_ADD_RADIO(page, R1, "set break = 30 min")
R4 = GW_ADD_RADIO(page, R1, "set break = 45 min")
R5 = GW_ADD_RADIO(page, R1, "use break times (E) and (F)")
GW_SHELF_NEWCELL(page)
tpause=gw_add_inputline(page,"(D) needed break duration in minutes","30")
gw_add_text(page,"")
gw_add_text(page,"")
bstart=gw_add_inputtime(page,"(E) Start breaktime",abstart$)
bstop=gw_add_inputtime(page,"(F) Stop breaktime",abstop$)

GW_SHELF_NEWrow(page)
gw_add_button(page, "(6) Save data local","savetext")
GW_SHELF_NEWcell(page)
gw_add_button(page, "(7) Send eMail","button6_SendMail")
gw_shelf_close(page)
helptext$+="Usage:\n"
helptext$+=" Given are two out of start time (A), stop time (B) and work duration (C)\n"
helptext$+=" Calculate the third one by pressing button (1) or (2).\n"
helptext$+="\n"
helptext$+="Set current time with buttons (3) or (4) if needed.\n"
helptext$+="Button (5) calculates work duration, if start and stop time are given.\n\n"
helptext$+="Button (6) stores start-, stop-, duration-, break-time and mail address\n" 
helptext$+="to be restored at next app start\n\n"
helptext$+="Break is calculated ...\n"
helptext$+=" if work_duration <= 6h then break = 0\n"
helptext$+=" if work_duration > 6h and <= 9h then break = 30 min\n"
helptext$+=" if work_duration <= 9h then break = 45 min\n"
helptext$+="Choose with (G) if break is set constant, calculated or\n"
helptext$+="set from user by (E) and (F)\n\n"
helptext$+="Button (7) creates an email with the calculated numbers\n\n"
helptext$+="contact the author at schurzmann@gmail.com"
gw_add_text(page,helptext$)

GW_RENDER(page)
DO
r$ = GW_WAIT_ACTION$()
if r$="savetext" then
  astart$=gw_get_value$(tstart)
  astop$=gw_get_value$(tstop)
  adur$=gw_get_value$(twork)
  apause$=gw_get_value$(tpause)
  abstart$=gw_get_value$(bstart)
  abstop$=gw_get_value$(bstop)

TEXT.OPEN W, FN1, "settings.txt"
TEXT.WRITELN FN1, astart$
TEXT.WRITELN FN1, astop$
TEXT.WRITELN FN1, adur$
TEXT.WRITELN FN1, apause$
TEXT.WRITELN FN1, amail$
TEXT.WRITELN FN1, abstart$
TEXT.WRITELN FN1, abstop$
TEXT.CLOSE FN1
popup "stored"
else if r$="button1_CalcStop" then
  s1$=gw_get_value$(tstart)
  s2$=gw_get_value$(twork)
  !GW_RENDER(page)
  startstunde=val(mid$(s1$,1,2))
  startminute=val(mid$(s1$,4,2))
  startzeit=startstunde*60+startminute
  arbeitsdauer=val(s2$)
  IF  GW_RADIO_SELECTED(R1) then
    if arbeitsdauer<=6*60 then
      p=0
    else 
      if arbeitsdauer<=9*60 then
        p=30
      else
        p=45
      end if
    end if
  ELSEIF  GW_RADIO_SELECTED(R2) then
    p=0
  ELSEIF  GW_RADIO_SELECTED(R3) then
    p=30
  ELSEIF  GW_RADIO_SELECTED(R4) then
    p=45
  ELSEIF  GW_RADIO_SELECTED(R5) then
    a$=gw_get_value$(bstart)
    b$=gw_get_value$(bstop)
    ah=val(mid$(a$,1,2))
    am=val(mid$(a$,4,2))
    bh=val(mid$(b$,1,2))
    bm=val(mid$(b$,4,2))
    p=(bh*60+bm)-(ah*60+am)
  ENDIF
  !print "p=";p
  stopzeit=startzeit+arbeitsdauer+p
  if stopzeit > 24*60 then
    stopzeit=stopzeit - (24*60)
  endif
  h2=int(stopzeit/60)
  m2=stopzeit-h2*60
  s3$=using$("","%02d",int(p))
  s4$=using$("","%02d",int(h2))
  s4$=s4$+":"+using$("","%02d",int(m2))
  s5$=str$(arbeitsdauer/60)+" h"
  gw_modify(tstart,"value",s1$)
  gw_modify(twork,"value",s2$)
  gw_modify(tpause,"value",s3$)
  gw_modify(tstop,"value",s4$)
  popup s1$+"\n"+s2$+"\n"+s3$+"\n"+s4$
elseif r$="button2_CalcStart" then
  !arbeitsbeginn
  s1$=gw_get_value$(tstop)
  s2$=gw_get_value$(twork)
  !GW_RENDER(page)
  stopstunde=val(mid$(s1$,1,2))
  stopminute=val(mid$(s1$,4,2))
  stopzeit=stopstunde*60+stopminute
  arbeitsdauer=val(s2$)
  IF  GW_RADIO_SELECTED(R1) then
    if arbeitsdauer<=6*60 then
      p=0
    else 
      if arbeitsdauer<=9*60 then
        p=30
      else
        p=45
      end if
    end if
  ELSEIF  GW_RADIO_SELECTED(R2) then
    p=0
  ELSEIF  GW_RADIO_SELECTED(R3) then
    p=30
  ELSEIF  GW_RADIO_SELECTED(R4) then
    p=45
  ELSEIF  GW_RADIO_SELECTED(R5) then
    a$=gw_get_value$(bstart)
    b$=gw_get_value$(bstop)
    ah=val(mid$(a$,1,2))
    am=val(mid$(a$,4,2))
    bh=val(mid$(b$,1,2))
    bm=val(mid$(b$,4,2))
    p=(bh*60+bm)-(ah*60+am)
  ENDIF
  startzeit=stopzeit-arbeitsdauer-p
  popup "beginn="+str$(startzeit)
  if startzeit < 0 then
    startzeit=24*60 + startzeit
  endif
  h2=int(startzeit/60)
  m2=startzeit-h2*60
  s3$=using$("","%02d",int(p))
  s4$=using$("","%02d",int(h2))
  s4$=s4$+":"+using$("","%02d",int(m2))
  s5$=str$(arbeitsdauer/60)+" h"
  gw_modify(tstop,"value",s1$)
  gw_modify(twork,"value",s2$)
!  gw_modify(tworkh,"text",s5$)
  gw_modify(tpause,"value",s3$)
  gw_modify(tstart,"value",s4$)
  popup s1$+"\n"+s2$+"\n"+s3$+"\n"+s4$
elseif r$="button3_CalcDur" then
  !arbeitszeit
  s1$=gw_get_value$(tstart)
  startstunde=val(mid$(s1$,1,2))
  startminute=val(mid$(s1$,4,2))
  startzeit=startstunde*60+startminute
  s2$=gw_get_value$(tstop)
  stopstunde=val(mid$(s2$,1,2))
  stopminute=val(mid$(s2$,4,2))
  stopzeit=stopstunde*60+stopminute
  !start=23:00 stop=4:00
  if startzeit > 16*60 then
    startzeit=24*60 - startzeit
    arbeitsdauer=stopzeit+startzeit
  else
    arbeitsdauer=stopzeit-startzeit
  endif
  s5$=str$(arbeitsdauer/60)+" h"
  ! get break value
  IF  GW_RADIO_SELECTED(R1) then
    if arbeitsdauer<=6*60 then
      p=0
    else 
      if arbeitsdauer<=9*60 then
        p=30
      else
        p=45
      end if
    end if
  ELSEIF  GW_RADIO_SELECTED(R2) then
    p=0
  ELSEIF  GW_RADIO_SELECTED(R3) then
    p=30
  ELSEIF  GW_RADIO_SELECTED(R4) then
    p=45
  ELSEIF  GW_RADIO_SELECTED(R5) then
    a$=gw_get_value$(bstart)
    b$=gw_get_value$(bstop)
    ah=val(mid$(a$,1,2))
    am=val(mid$(a$,4,2))
    bh=val(mid$(b$,1,2))
    bm=val(mid$(b$,4,2))
    p=(bh*60+bm)-(ah*60+am)
  ENDIF
  arbeitsdauer=arbeitsdauer-p
  s4$=using$("","%02d",int(arbeitsdauer))
  s3$=using$("","%02d",int(p))
  gw_modify(tstart,"value",s1$)
  gw_modify(twork,"value",s4$)
!  gw_modify(tworkh,"text",s5$)
  gw_modify(tpause,"value",s3$)
  gw_modify(tstop,"value",s2$)
  popup s1$+"\n"+s2$+"\n"+s3$+"\n"+s4$
elseif r$="button4_SetStart" then
  !setze start auf aktuelle Zeit
  TIME yy$,mm$,dd$,hh$,min$,ss$,wd,isDST
  s1$=using$("","%02d",int(val(hh$)))
  s1$=s1$+":"+using$("","%02d",int(val(min$)))
  s2$=gw_get_value$(twork)
  s3$=str$(val(s2$)/60)
  s4$=gw_get_value$(tpause)
  s5$=gw_get_value$(tstop)
  !GW_RENDER(page)
  gw_modify(tstart,"value",s1$)
  gw_modify(twork,"value",s2$)
!  gw_modify(tworkh,"text",s3$)
  gw_modify(tpause,"value",s4$)
  gw_modify(tstop,"value",s5$)
  popup s1$+"\n"+s2$+"\n"+s3$+"\n"+s4$
elseif r$="button5_SetStop" then
  !setze stop auf aktuelle Zeit
  TIME yy$,mm$,dd$,hh$,min$,ss$,wd,isDST
  s1$=gw_get_value$(tstart)
  s2$=gw_get_value$(twork)
  s3$=str$(val(s2$)/60)
  s4$=gw_get_value$(tpause)
  s5$=using$("","%02d",int(val(hh$)))
  s5$=s5$+":"+using$("","%02d",int(val(min$)))
  !GW_RENDER(page)
  gw_modify(tstart,"value",s1$)
  gw_modify(twork,"value",s2$)
!  gw_modify(tworkh,"text",s3$)
  gw_modify(tpause,"value",s4$)
  gw_modify(tstop,"value",s5$)
  popup s1$+"\n"+s2$+"\n"+s3$+"\n"+s4$

elseif r$="button6_SendMail"
  text.input mailaddr$,amail$,"Target mail address"
  amail$=mailaddr$
  mailtitle$="working time"
  mailbody$="start="+gw_get_value$(tstart)
  mailbody$=mailbody$+";stop="+gw_get_value$(tstop)
  mailbody$=mailbody$+";work="+gw_get_value$(twork)
  mailbody$=mailbody$+";pause="+gw_get_value$(tpause)
  mailbody$=mailbody$+";breakstart="+gw_get_value$(bstart)
  mailbody$=mailbody$+";breakstop="+gw_get_value$(bstop)
  text.input mailbody$,mailbody$,"Mail body"
  Email.send mailaddr$, mailtitle$, mailbody$
endif
UNTIL r$ = "BACK"




