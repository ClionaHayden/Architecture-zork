 org $1000

*-------------------------------------------------------
*Choose to be Evil Wizard or New Romancers
*-------------------------------------------------------

*-------------------------------------------------------
*Validation values to be used, modify as needed
*Add additional validation values as required
*-------------------------------------------------------
exit        EQU 0      used to exit assembly program
min_feed    EQU 100    min feed requirement
min_horses  EQU 1      min number of horses
max_horses  EQU 9      max number of horses
min_soldier EQU 6      min soldiers
min_charge  EQU 1      min rate of fuel use based of speed (oats for horses)
max_charge  EQU 5      max rate e.g. Flank       
hit_point   EQU 5      points accumilated on castle (objective) strike
miss_point  EQU 8      points deducted for ordinace miss
horse_cost  EQU 20

mine_loc    EQU 100    example for a hit

* H0RSE FEED LOCATION: $2000, W
* HORSE AMOUNT LOCATION: $2500 W
* GOLD LOCATION: $1600 B


*Start of Game
start:
    move.b  #100,$4000 put score/health in memory location $4000
    move.w  #5000,$1600
    lea     $4000,A3   assign address A3 to that memory location
    bsr     welcome    branch to the welcome subroutine
    bsr     choice1GE
    bsr     Stable
    bsr     input      branch to the input subroutine
    bsr     game       branch to the game subroutine
*Game loop
    org     $3000      the rest of the program is to be located from 3000 onwards

*-------------------------------------------------------
*-------------------Game Subroutine---------------------
*-------------------------------------------------------
game:
    bsr     gameloop   branch to gameloop subroutine
    rts                return from game: subroutine
          
end:
    simhalt

*-------------------------------------------------------
*-------------------Welcome Subroutine------------------
*-------------------------------------------------------
welcome:
    bsr     endl            branch to endl subroutine
    lea     welcome_msg,A1  assign message to address register A1 

    move.b  #14,D0          move literal 14 to DO
    trap    #15             trap and interpret value in D0
    
    bsr     endl
    lea      welcome_msg2,A1  
    move.b  #14,D0         
    trap    #15            
    
    bsr     endl            branch to endl subroutine
    rts                     return from welcome: subroutine

*-------------------------------------------------------
*---------------Choice 1: good or evil------------------
*-------------------------------------------------------
choice1GE:
       *output text
    lea     choice_good_evil,A1
    move.b  #14,D0
    trap    #15
    *get input
    move.b  #4,D0
    trap    #15
    
    *branch to choice
    cmp     #1,D1
    beq     GoodChoice
    
    cmp     #2,D1
    beq     EvilChoice
    bgt     ErrorChoice1
    
     
    
GoodChoice:
    lea     GoodChoice_msg,A1
    move.b  #14,D0
    trap    #15
    rts

EvilChoice:
    lea     EvilChoice_msg,A1
    move.b  #14,D0
    trap    #15
    rts
    
    *--------------------------
    *-------Stable Text--------
    *--------------------------
Stable:
    lea     Stable_msgStart,A1
    move.b  #14,D0
    trap    #15
    
    *display player gold message
    lea     Gold_msg,A1
    move.b  #14,D0
    trap    #15
    
    *display player gold amount
    move.w  $1600, D1
    move.b  #3,D0
    trap    #15
    
    lea     crlf,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15
    move.b  D1,D2
    mulu.w    horse_cost,D2
    add.w     D2, ($1600)
    
    *display player gold message
    lea     Gold_msg,A1
    move.b  #14,D0
    trap    #15
    
    *display player gold amount
    move.w  $1600, D1
    move.b  #3,D0
    trap    #15
    
    rts

    
*-------------------------------------------------------
*--------------------Error message----------------------
*-------------------------------------------------------
ErrorChoice1:
    lea     Error_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     choice1GE


*-------------------------------------------------------
*---------Gameplay Input Values Subroutine--------------
*-------------------------------------------------------    
input:
    bsr     feed            branch to feed input subroutine
    bsr     horses          branch to ship input subroutine
    bsr     rate            branch to rate (charging speed) input subroutine
    bsr     distance        branch to mission distance/location input subroutine
    bsr     soldiers        branch to soldiers input subroutine
    rts

*-------------------------------------------------------
*----------------Gameloop (main loop)-------------------
*------------------------------------------------------- 
gameloop:
    bsr     update          branch to update game subroutine 
    bsr     clear_screen    clears the screen         
    bsr     draw            branch to draw screen subroutine
    bsr     clear_screen    clears the screen
    bsr     gameplay        branch to gameplay subroutine
    bsr     clear_screen    clears the screen
    bsr     hud             branch to display HUD subroutine
    bsr     clear_screen    clears the screen
    bsr     replay          branch to replay game subroutine
    bsr     clear_screen    clears the screen
    rts                     return from gameloop: subroutine

*-------------------------------------------------------
*---------------Update Mission Progress-----------------
*  Move to battle location, engage enemy, fire and take
*  fire, complete mission and return to base
*------------------------------------------------------- 
update:
    bsr     endl            print a CR and LF
    bsr     decorate        decorate with dots using a loop
    lea     update_msg,A1   
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts
*-------------------------------------------------------
*---------------Draw Mission Updates--------------------
* Draw the game progress information, status regarding
* mission
*------------------------------------------------------- 
draw:
    bsr     endl
    bsr     decorate
    lea     draw_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts
*-------------------------------------------------------
*-----------------------Horse feed-----------------------
* Input the feed load for each horse. Feed costs money
* For an advanced mark you need to manage this resource
*------------------------------------------------------- 
feed:
    bsr     endl
    bsr     decorate
    lea     feed_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    TRAP    #15
    
    ADD     D1, $2000
    
    bsr     decorate
    rts

*-------------------------------------------------------
*--------------------Horses Inventory---------------------
* Number of horses to be allocated to a mission 
*------------------------------------------------------- 
horses:
    bsr     endl
    bsr     decorate
    lea     horses_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    TRAP    #15
    
    ADD  D1, $2500
    
    bsr     decorate
    rts

*-------------------------------------------------------
*-------------------Horse(s) Charge Speed---------------
* horses speed to and from a mission
*------------------------------------------------------- 
rate:
    bsr     endl
    bsr     decorate
    lea     rate_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts

*-------------------------------------------------------
*------------------Mission Distance---------------------
* Distance to battle location
*------------------------------------------------------- 
distance:
    bsr     endl
    bsr     decorate
    lea     distance_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts

*-------------------------------------------------------
*-----------------------Soldiers----------------------
* Number of soldiers
*-------------------------------------------------------   
soldiers:
    bsr     endl
    bsr     decorate
    lea     soldiers_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts

*-------------------------------------------------------
*---Game Play (Mission Progress, Battle Maneuvers)------
*------------------------------------------------------- 
gameplay:
    bsr     endl
    bsr     decorate
    lea     gameplay_msg,A1
    move.b  #14,D0
    trap    #15
    
    bsr     decorate
    bsr     collision
    rts

*-------------------------------------------------------
*-----------------Heads Up Display (Score)--------------
* Retrieves the score from memory location
*-------------------------------------------------------   
hud:

    bsr     endl
    bsr     decorate
    lea     hud_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  (A3),D1     retrieve the value A3 point to and move to D1
    move.b  #3,D0       move literal 3 to D0
    trap    #15         intrepret value in D0, which 3 which displays D1
    
    * output current amount of horse feed
    LEA     current_feed_msg, A1
    move.w  $2000, D1       
    move.b  #17, D0
    trap    #15
    
    bsr     decorate
    rts

*-------------------------------------------------------
*-----------------------Taking Fire---------------------
* This could be used for collision detection, if 
*-------------------------------------------------------
collision:
    move.b  #mine_loc,D1
    cmp     #100,D1 is( x == 100)?
	bne     collision_miss if x is equal to 100, then hit
collision_hit:
    *hit
    lea     hit_msg,A1
    move    #14,D0
    trap    #15
    rts
    
collision_miss:
    *miss
    lea     miss_msg,A1
    move    #14,D0
    trap    #15
    rts

*-------------------------------------------------------
*--------------------------Loop-------------------------
*-------------------------------------------------------
loop:
    move.b  #5, D3 loop counter D3=5
next:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     next    repeat until D0=0

*-------------------------------------------------------
*------------------Screen Decoration--------------------
*-------------------------------------------------------
decorate:
    move.b  #60, D3
    bsr     endl
out:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     out	    repeat until D0=0
    bsr     endl
    rts
    
clear_screen: 
    move.b  #11,D0      clear screen
    move.w  #$ff00,D1
    trap    #15
    rts
*-------------------------------------------------------
*------------------------Replay-------------------------
*-------------------------------------------------------
replay:
    bsr     endl
    lea     replay_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15

    cmp     #exit,D1
    beq     end         if SR Z register contains 1 beq => Branch Equals
    bsr     gameloop

endl:
    movem.l D0/A1,-(A7)
    move    #14,D0
    lea     crlf,A1
    trap    #15
    movem.l (A7)+,D0/A1
    rts
    
*-------------------------------------------------------
*-------------------Data Delarations--------------------
*-------------------------------------------------------

crlf:           dc.b    $0D,$0A,0
welcome_msg:    dc.b    '************************************************************'
                dc.b    $0D,$0A
                dc.b    'ZorkQuest: Assault on Egreth Castle'
                dc.b    $0D,$0A
                dc.b    '************************************************************'
                dc.b    $0D,$0A,0
                
break_msg:      dc.b    $0D,$0A
                dc.b    'Press Enter to continue'
                dc.b    $0D,$0A,0
                
              
welcome_msg2:   dc.b    $0D,$0A
                dc.b    'Welcome to the bustling city of Alexandria! Once the grounds of many'
                dc.b    $0D,$0A 
                dc.b    'great battles,Alexandria has become a peaceful harbour city' 
                dc.b    $0D,$0A
                dc.b    'with a rich culture and even richer coin purses.However, this peace had' 
                dc.b    $0D,$0A
                dc.b    'become shortlived as a malevolent power grew in the snow - capped' 
                dc.b    $0D,$0A
                dc.b    'mountains far to the north-west. Fearing the potential threat to his'
                dc.b    $0D,$0A
                dc.b    'kingdom, King Regis Lucis Caelum III has sent you, Karliah Crescent,'
                dc.b    $0D,$0A
                dc.b    'to investigate the strange lights that recently appeared over '
                dc.b    $0D,$0A
                dc.b    'the Eldin mountains to the north. You have full access to the royal'
                dc.b    $0D,$0A
                dc.b    'armory and are to bring a small army with you on your investigation.'
                dc.b    $0D,$0A
                dc.b    'Upon reieving this request, you pick up your armour and sword and'
                dc.b    $0D,$0A
                dc.b    'leave the castle. ' 
                dc.b    $0D,$0A,0
                
                *--------------------------------------------
                *----------Text for first choice-------------
                *--------------------------------------------
                
choice_good_evil: dc.b    $0D,$0A
                  dc.b    $0D,$0A
                  dc.b    'On your way to the stables you feel as if you are being watched.'
                  dc.b    $0D,$0A
                  dc.b    'You turn to see a young girl dressed in rags following you down'
                  dc.b    $0D,$0A
                  dc.b    'the road. Scared by your sudden movement, the girl jumps and'
                  dc.b    $0D,$0A
                  dc.b    'quietly says, "Excuse me miss, but could you spare a coin? My'
                  dc.b    $0D,$0A
                  dc.b    'parents died in the war". Will you:'
                  dc.b    $0D,$0A
                  dc.b    '1. Give the girl a gold coin'
                  dc.b    $0D,$0A
                  dc.b    '2. Spit on the girl'
                  dc.b    $0D,$0A,0
                  
GoodChoice_msg: dc.b    $0D,$0A
                dc.b    $0D,$0A
                dc.b    'The girl enthusiastically grabbed the coin from your hand and skipped'
                dc.b    $0D,$0A
                dc.b    'down the road in glee. feeling as if you have done your good deed for the'
                dc.b    $0D,$0A
                dc.b    'day, you continue down the road towards the stables'
                dc.b    $0D,$0A,0

EvilChoice_msg: dc.b    $0D,$0A
                dc.b    $0D,$0A
                dc.b    'You spit at the girl in disgust, hitting her in the face. Horrified, she'
                dc.b    $0D,$0A
                dc.b    'sprints away. The people on the street noticed what you did and try to'
                dc.b    $0D,$0A
                dc.b    'avoid eye contact with you as they hurry past. You continue your walk to'
                dc.b    $0D,$0A
                dc.b    'the stables as if nothing has happened.'
                dc.b    $0D,$0A,0

                  
Error_msg:
                  dc.b    $0D,$0A
                  dc.b    'Error: invalid input, please try again'
                  dc.b    $0D,$0A,0
                 
                *-------------------------------------
                *-----------Text for stable-----------
                *------------------------------------- 
Stable_msgStart:
                  dc.b    $0D,$0A
                  dc.b    'You arrive at the stables and try to find someone that will give you'
                  dc.b    $0D,$0A
                  dc.b    'horses for your army. You meet with the stablemaster, who says it will'
                  dc.b    $0D,$0A
                  dc.b    'cost 20 gold for a horse and 1 gold for each unit of feed you buy'
                  dc.b    $0D,$0A
                  dc.b    'How many horses will you buy?'
                  dc.b    $0D,$0A,0
                  
Stable_msgEnd:    dc.b    $0D,$0A
                  dc.b    'How much feed will you buy?'
                  dc.b    $0D,$0A,0
                  
Gold_msg:         dc.b    $0D,$0A
                  dc.b    'Gold: ',0
                   
                  
                  *--------------------------------------------
                  *------------Text for the forest-------------
                  *--------------------------------------------


feed_msg:       dc.b    'Feed load (each horse needs at least 100 units of feed)'
                dc.b    $0D,$0A
                dc.b    'Enter feed load : ',0
                
current_feed_msg:       dc.b    'Current Feed:'
                        dc.b    $0D,$0A
                        
horses_msg:     dc.b    'Number of horses : ',0
rate_msg:       dc.b    'One Third[1], Two Thirds[2], Standard Charge[3], ' 
                dc.b    $0D,$0A
                dc.b    'Full Charge[4], Flank Charge[5] units feed per click'
                dc.b    $0D,$0A
                dc.b    'Enter Speed : ',0
distance_msg:   dc.b    'Mission distance e.g. 40 (with 100 units of feed  '
                dc.b    $0D,$0A
                dc.b    'One Third speed 20 units remain for manuvouirs) horses '
                dc.b    $0D,$0A
                dc.b    'Horses without feed are lost.'
                dc.b    $0D,$0A
                dc.b    'Enter mission distance : ',0
soldiers_msg:       dc.b    'Each horses need at least 1 Knight and an Stable Hand'
                dc.b    $0D,$0A
                dc.b    'minimum requirement is 2 i.e. Stable Hand x 1 and Knight x 1.'
                dc.b    $0D,$0A
                dc.b    'Enter # of soldiers : ',0
gameplay_msg:   dc.b    'Add Gameplay !',0
update_msg:     dc.b    'Update Gameplay !',0
draw_msg:       dc.b    'Draw Screen !',0
hit_msg:        dc.b    'Strike!',0
miss_msg:       dc.b    'Miss!',0
loop_msg:       dc.b    '.',0
replay_msg:     dc.b    'Enter 0 to Quit any other number to replay : ',0
hud_msg:        dc.b    'Score : ',0

health:     ds.w    1
score:      ds.w    1 reserve space for score

    end start



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
