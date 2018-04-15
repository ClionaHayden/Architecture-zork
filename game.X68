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

mine_loc    EQU 100    example for a hit

* H0RSE FEED LOCATION: $2000, W
* HORSE AMOUNT LOCATION: $2500 W
* GOLD LOCATION: $1600 W
* RATE FOR HIRING MERC  $1800 W
* SOLDIER AMOUNT LOCATION $1900 W


*Start of Game
start:
    move.b  #100,$4000 put score/health in memory location $4000
    move.w  #10000,$1600
    move.w  #0, $2000
    move.w  #0, $2500
    move.w  #0, $1900
    move.w  #250,$1800
    lea     $4000,A3   assign address A3 to that memory location
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
    lea     welcome_msg2,A1  
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
    *buy horses
    lea     Stable_msgStart,A1
    move.b  #14,D0
    trap    #15
    
    bsr DisplayGold
    
    lea     crlf,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15
    
    bsr       BuyHorses
    
    *display player gold and horses messages
    bsr DisplayGold
    bsr DisplayHorses
    
    *buy feed
    lea     Stable_msgEnd,A1
    move.b  #14,D0
    trap    #15
    
    bsr     DisplayGold
    
    move.b  #4,D0
    trap    #15
    bsr     BuyFeed
    
    
    bsr     endl
    
    *display player gold,horses and feed messages
    bsr DisplayGold
    bsr DisplayHorses
    bsr DisplayFeed
    
    rts
    
    *----------------------------------
    *-----------Tavern Text------------
    *----------------------------------
Tavern:
    bsr     TavernStart
    bsr     TavernEnd
    
    rts
    
TavernStart:
    lea     BarracksStart_msg,A1
    move.b  #14,D0
    trap    #15
    
    *get input
    move.b  #4,D0
    trap    #15
    
    cmp     #2,D1
    blt     BarterLost
    
    cmp     #1,D1
    beq     BarterWon
    
    rts
    
BarterWon:
    lea     BarterWon_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.w  #150,$1800
    bsr     TavernEnd
    
BarterLost:
    lea gameOver_msg_lostBarter,A1
    move.b  #14,D0
    trap    #15
    
    bsr     replay
    
    
TavernEnd:
    lea     TavernEnd_msg,A1
    move.b  #14,D0
    trap    #15
    
    bsr     DisplayGold
    
    move.b  #4,D0
    trap    #15
    bsr     BuySoldiers
    
    bsr     DisplayResources
 
    lea     Tavern_final_msg,A1
    move.b  #14,D0
    trap    #15   
    
    rts
    
*----------------------------------
*--------------Forest--------------
*----------------------------------
Forest:
    bsr Forest_Start
    rts


Forest_Start:

    lea     Forest_start_msg,A1
    move.b  #14,D0
    trap    #15
    
    bsr     ForestChoice
    rts
    
ForestChoice:
    lea     Forest_choice_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15
    
    move.l  #1,D3
    cmp     D3,D1
    beq     ForestDescription
    
    move.l  #2,D3
    cmp     D3,D1
    beq     LeftPath
    
    move.l  #3,D3
    cmp     D3,D1
    beq     RightPath
    
    rts
    
ForestDescription:
    lea     Forest_description_msg_road,A1
    move.b  #14,D0
    trap    #15
    
    lea     Forest_choice_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15
    
    move.l  #1,D2
    cmp     D2,D1
    beq     ForestDescription
    
    move.l  #2,D2
    cmp     D2,D1
    beq     LeftPath
    
    move.l  #3,D2
    cmp     D2,D1
    beq     RightPath
    
    rts
    
LeftPath:
    bsr     Rest
    bsr     DisplayResources
    
    lea     Forest_left_path,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15
    
    move.w  #1,D2
    cmp     D2,D1
    beq     Scout
    
    move.w  #2,D2
    cmp     D2,D1
    beq     Continue
    
    move.w  #0,D2
    rts
Scout:
    lea     scout_msg,A1
    move.b  #14,D0
    trap    #15
    
    
    move.w  $1900, D4
    sub.w   #15, D4 * take soldiers
    move.w  D4, $1900
    
    move.w  $2000,D4
    sub.w   #150,D4 * take feed
    move.w  D4, $2000
    
    move.w  $2500,D4
    sub.w   #3,D4       *take horses
    move.w  D4, $2500
    
    bsr     CheckGameOver
    
    bsr     DisplayResources
    
    move.b  #0,D1


Continue:
    lea     continue_text,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #0,D1


RightPath:
    bsr     Rest
    bsr     DisplayResources
    
    lea     forest_right_path,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15
    
    move.w  #1,D2
    cmp     D2,D1
    beq     Leave_horses
    
    move.w  #2,D2
    cmp     D2,D1
    beq     Save_horses
    
    move.b  #0,D1
    rts
    
    
Save_horses:
    lea     Save_horses_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.w  $2500,D4
    sub.w   #2,D4       *take horses
    move.w  D4, $2500
    
    move.w  $1900, D4
    sub.w   #5, D4 * take soldiers
    move.w  D4, $1900
    
    bsr     CheckGameOver
    
    move.b  #0,D1
    bsr     DisplayResources
    
    move.b  #0,D1
    rts
 

Leave_horses:
    lea     Leave_horses_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.w  $2500,D4
    sub.w   #5,D4       *take horses
    move.w  D4, $2500
    
    bsr     CheckGameOver
    
    move.b  #0,D1
    bsr     DisplayResources
    
    move.b  #0,D1
      

Rest:
    lea     Rest_msg,A1
    move.b  #14,D0
    trap    #15
    
    bsr     loseHorses
    bsr     DisplayResources
    rts
    

    
*--------------------------------------------------
*---------------Mountain/Castle--------------------
*--------------------------------------------------
Mountain:
    bsr MountainStart
    
    
    rts
    


MountainStart:
    lea     Mountain_start_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15
    
    move.l  #1,D3
    cmp     D3,D1
    beq     Killed
    
    move.l  #2,D3
    cmp     D3,D1
    beq     Captured
    
    move.l  #3,D3
    cmp     D3,D1
    beq     Fight
    
    rts
    
Killed:
    lea     Killed_msg,A1
    move.b  #14,D0
    trap    #15
    
    bsr     Replay

Captured:
    lea     Captured_msg,A1
    move.b  #14,D0
    trap    #15
    
    bsr     Replay

Fight:
    lea     fight_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.l  #15,D3
    cmp     #15,($1900) 
    bgt     Fight_lost
    beq     Fight_won
    blt     Fight_won
    
Fight_won:
    lea     fight_won_msg,A1
    move.b  #14,D0
    trap    #15
    
    bsr     Replay

Fight_lost:    
    lea     fight_lost_msg,A1
    move.b  #14,D0
    trap    #15

    bsr     Replay



    
*-------------------------------------------------------
*-------------------game over messages------------------
*-------------------------------------------------------    
    
GameOver_gold:
    bsr   decorate
    lea   GameOver_msg_gold,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate

    bsr     replay

GameOver_soldiers:
    bsr     decorate
    lea     GameOver_msg_soldiers,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate

    bsr     replay 

GameOver_horses:
    bsr     decorate
    lea     GameOver_msg_horses,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate

    bsr     replay 
    
CheckGameOver:  
    cmp     #0, $1600 * gold
    blt     GameOver_gold
    
    cmp     #0, $2500 * horses
    blt     GameOver_horses
    
    cmp     #0, $1900 * soldiers
    blt     GameOver_soldiers
    
    rts
    
    

    
*------------------------------------------------------
*-------------Display the player's inventory-----------
*------------------------------------------------------
DisplayGold:
    lea     Gold_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.w  $1600, D1
    move.b  #3,D0
    trap    #15
    bsr     endl
    rts
    
DisplayHorses:
    lea     horses_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.w  $2500, D1
    move.b  #3,D0
    trap    #15
    bsr     endl
    rts
    
DisplayFeed:
    lea     current_feed_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.w  $2000, D1
    move.b  #3,D0
    trap    #15
    bsr     endl
    rts
    
DisplaySoldiers:
    lea     current_soldiers_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.w  $1900, D1
    move.b  #3,D0
    trap    #15
    bsr     endl
    rts
    
DisplayResources:
    bsr DisplayGold
    bsr DisplayHorses
    bsr DisplayFeed
    bsr DisplaySoldiers
    
    rts
    
*------------------------------------------------------
*--------------------Buy Resources---------------------
*------------------------------------------------------
BuyHorses:
    add.w  D1,$2500 *store horses inputted in $2500
    move.w  D1,D2
    muls.w    #20,D2
    sub.w     D2, ($1600)
    
    cmp       #0,$1600
    blt       GameOver_gold
    
    rts

BuyFeed:
    add.w       D1,($2000) *store feed in $2000
    move.w      D1,D2
    muls.w      #1,D2
    sub.w       D2, ($1600)
    
    cmp       #0,$1600
    blt       GameOver_gold
    
    rts
    
BuySoldiers:

    add.w       D1,($1900) *store soldiers in $1900
    move.w      D1,D2
    muls.w      ($1800),D2
    sub.w       D2, ($1600)
    
    cmp       #0,$1600
    blt       GameOver_gold
    
    rts
    
    *---------------------
    *---Lose Resourses----
    *---------------------
    
LoseHorses:
    move.w  ($2500),D4 *amount of horses 
    move.w  ($2000),D5 *amount of feed
    
    move.w   D3,D6
    muls.w  #50, D6
    cmp     D6,D5
    bgt     FeedHorses
    blt     gameOver_horses
    
    divs.w  #50, D6
    
    rts
    
FeedHorses:
    move.w  ($2500),D3
    move.w   D3,D4
    muls.w  #50, D4
    
    sub.w   D4, ($2000)
    
    rts
    



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
    bsr     welcome    branch to the welcome subroutine
    bsr     endl            print a CR and LF
    bsr     decorate        decorate with dots using a loop
    
    bsr     choice1GE
    bsr     decorate
    
    bsr     Stable
    bsr     decorate
    
    bsr     Tavern
    bsr     decorate
    bsr     break
    
    bsr     clear_screen
    
    bsr     Forest
    bsr     decorate
    
    bsr     Break
    bsr     Clear_screen
    bsr     Mountain
    
    bsr     decorate
    bsr     Break
    
    bsr     Replay
    
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
    
    
    *-----------------
    *------Break------
    *-----------------
    
Break:
      lea   continue_msg, A1
      move.b  #14,D0
      trap    #15
      
      move.b  #4,D0
      trap    #15
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
* reset values
    move.b  #100,$4000 put score/health in memory location $4000
    move.w  #10000,$1600
    move.w  #0, $2000
    move.w  #0, $2500
    move.w  #0,$1900
    move.w  #250,$1800
    lea     $4000,A3   assign address A3 to that memory location
    
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
                
GameOver_msg_gold:   dc.b    $0D,$0A
                dc.b    'As you travel along the path you come accross a small tavern.'
                dc.b    $0D,$0A
                dc.b    'You decide to take a well deserved break from all this leading'
                dc.b    $0D,$0A
                dc.b    'business and walk up to the counter. You order your usual and'
                dc.b    $0D,$0A
                dc.b    'reach into your coin pouch to pay, but unfortunately all you '
                dc.b    $0D,$0A
                dc.b    'find in there is two buttons and a bit of lint. As you try to'
                dc.b    $0D,$0A
                dc.b    'come up with an excuse for the bartender, you feel a large'
                dc.b    $0D,$0A
                dc.b    'behind you. As you turn you see two large bouncers staring'
                dc.b    $0D,$0A
                dc.b    'menacingly at you. As you go to draw your sword they pick you'
                dc.b    $0D,$0A
                dc.b    'up and throw you into the nearest puddle, much to the amusement'
                dc.b    $0D,$0A
                dc.b    'of the other patrons.'
                dc.b    $0D,$0A
                dc.b    $0D,$0A
                dc.b    'GAME OVER - out of gold'
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
                  dc.b    'How much feed will you buy?(each horse needs at least 50 units of feed)'
                  dc.b    $0D,$0A,0
                  
Gold_msg:         dc.b    $0D,$0A
                  dc.b    'Gold: ',0
                   
                   
                  *----------------------------------------
                  *--------Text for barracks/tavern--------
                  *----------------------------------------
BarracksStart_msg:
                   dc.b    $0D,$0A
                   dc.b    'After acquiring the mounts you needed from the stable, you head out'
                   dc.b    $0D,$0A
                   dc.b    'to look for people who will fight for your cause. You find yourself'
                   dc.b    $0D,$0A   
                   dc.b    'in the barracks of the royal army. As you are walking through, you'
                   dc.b    $0D,$0A
                   dc.b    'see a new looking poster on the wall, "Merceneries for Hire". Your'
                   dc.b    $0D,$0A
                   dc.b    'eyes light up as you make your way to the tavern to seek out these'
                   dc.b    $0D,$0A
                   dc.b    'sellswords. Upon entering, you see a large group of around 250 tough.'
                   dc.b    $0D,$0A
                   dc.b    'looking men and women downing tankards of mead and sparring with each'
                   dc.b    $0D,$0A
                   dc.b    'other. You pull up a chair at the table with what looks like their'
                   dc.b    $0D,$0A
                   dc.b    'leader. He analyses you for a moment before saying, "What is a pretty'
                   dc.b    $0D,$0A
                   dc.b    'lass like you doing in a rough place like this, eh?". The both of you'
                   dc.b    $0D,$0A
                   dc.b    'chat for a while and when you mention that you are looking for soldiers'
                   dc.b    $0D,$0A
                   dc.b    'he immediately buts in, "We are up for hire, miss, and by the looks of'
                   dc.b    $0D,$0A
                   dc.b    'that crest on your shoulder, you can afford us". His current asking price'
                   dc.b    $0D,$0A
                   dc.b    'is 250 gold per soldier. Will you:'
                   dc.b    $0D,$0A 
                   dc.b    $0D,$0A 
                   dc.b    '1: Barter for a discount'
                   dc.b    $0D,$0A
                   dc.b    '2: Accept his offer'
                   dc.b    $0D,$0A
                   dc.b    'Other: Demand they work for free'
                   dc.b    $0D,$0A,0

gameOver_msg_lostBarter:
                   dc.b    $0D,$0A 
                   dc.b    'Before you finished your sentence, you find a sword in your chest. Maybe'
                   dc.b    $0D,$0A
                   dc.b    'trying to intimidate these guys was not the brightest of ideas.'
                   dc.b    $0D,$0A
                   dc.b    $0D,$0A
                   dc.b    'GAME OVER'
                   dc.b    $0D,$0A,0

barterWon_msg:     dc.b    $0D,$0A 
                   dc.b    'After a bit of deliberation with the rest of the group, the leader returns'
                   dc.b    $0D,$0A
                   dc.b    'saying that they can do 150 gold but that is as low as they can go.'
                   dc.b    $0D,$0A,0  
                   
TavernEnd_msg:     dc.b    $0D,$0A
                   dc.b    'Deciding it is probably best is you do not anger this guy, you decide to'
                   dc.b    $0D,$0A
                   dc.b    'accept their offer. Delighted with this response, the leader glances at'
                   dc.b    $0D,$0A
                   dc.b    'his skilled fighters and then turns back to you. "So, how many of us'
                   dc.b    $0D,$0A
                   dc.b    'are ye looking to hire?"'
                   dc.b    $0D,$0A
                   dc.b    $0D,$0A
                   dc.b    'How many soldiers will you hire?'
                   dc.b    $0D,$0A,0
                   
Tavern_final_msg:  dc.b    $0D,$0A
                   dc.b    'Happy with your final offer, the leader stands up, enthusiastically shakes'
                   dc.b    $0D,$0A
                   dc.b    'your hand and raises a tankard in your honour. You and your newfound army'
                   dc.b    $0D,$0A
                   dc.b    'set off at dawn to seek the threat of this kingdoms peace at last'
                   dc.b    $0D,$0A,0
            
                  *--------------------------------------------
                  *------------Text for the forest-------------
                  *--------------------------------------------
Forest_start_msg: dc.b    $0D,$0A
                  dc.b    'Dawn soon arrives as you pack your things. Ready to finally head out, you'
                  dc.b    $0D,$0A
                  dc.b    'head out to join your army, who are preparing your horses. You take out'
                  dc.b    $0D,$0A 
                  dc.b    'the slightly tattered map and head in the direction of the mountain. As'
                  dc.b    $0D,$0A
                  dc.b    'you progress, you enter a large forest. Further inspection of the map'
                  dc.b    $0D,$0A 
                  dc.b    'reveals that you have entered the "Lost Woods", known for its tendancy'
                  dc.b    $0D,$0A 
                  dc.b    'to get adventurers lost, never to return. You continue along the path'
                  dc.b    $0D,$0A 
                  dc.b    'until you come accross a fork in the road.'
                  dc.b    $0D,$0A 
                  dc.b    $0D,$0A,0
                  
Forest_choice_msg:
                  dc.b    'What will you do?'
                  dc.b    $0D,$0A 
                  dc.b    $0D,$0A
                  dc.b    '1. Look around the area'
                  dc.b    $0D,$0A 
                  dc.b    '2. Take the left path'
                  dc.b    $0D,$0A 
                  dc.b    '3. Take the right path' 
                  dc.b    $0D,$0A,0  

Forest_description_msg_road:
                  dc.b    $0D,$0A
                  dc.b    'Upon closer inspection, you see thst the path to the right seems to'
                  dc.b    $0D,$0A
                  dc.b    'have more mud and water on it that the other path. The path to the'
                  dc.b    $0D,$0A
                  dc.b    'left seems to have more foot traffic on it. There is also some evidence'
                  dc.b    $0D,$0A
                  dc.b    'of horse prints on the left path.'
                  dc.b    $0D,$0A
                  dc.b    $0D,$0A,0 

Forest_left_path:
                  dc.b    $0D,$0A
                  dc.b    'You decide that the left path looks the safest and choose to lead your'
                  dc.b    $0D,$0A
                  dc.b    'army that way. The road seems normal for about half a day then, out of'
                  dc.b    $0D,$0A
                  dc.b    'nowhere, you hear a loud scream coming from a small clump of trees'
                  dc.b    $0D,$0A
                  dc.b    'on the other side of a clearing.'
                  dc.b    $0D,$0A
                  dc.b    $0D,$0A
                  dc.b    'What will you do?'
                  dc.b    $0D,$0A
                  dc.b    '1. Send a scout to see what the sound was'
                  dc.b    $0D,$0A
                  dc.b    '2. Continue as if nothing happened'
                  dc.b    $0D,$0A,0

Scout_msg:
                  dc.b    $0D,$0A
                  dc.b    'You send two of your weakest looking soldiers towards the trees to scout'
                  dc.b    $0D,$0A
                  dc.b    'the area. A few seconds pass, then an minute, then an hour. After about'
                  dc.b    $0D,$0A
                  dc.b    'an hour and a half, you are about to give up hope of them returning, until'
                  dc.b    $0D,$0A
                  dc.b    'you see one of them running towards you in a blind panic. You see a large'
                  dc.b    $0D,$0A
                  dc.b    'of flying creatures chasing him. As they get closer to the sunlight of the'
                  dc.b    $0D,$0A
                  dc.b    'forest clearing, you can see their true form. "HARPIES!!" A group of about'
                  dc.b    $0D,$0A
                  dc.b    'twenty harpies swoop down and start attacking your army. After every last'
                  dc.b    $0D,$0A
                  dc.b    'one is slain, you  access the damage of the battle.'
                  dc.b    $0D,$0A
                  dc.b    $0D,$0A
                  dc.b    'You lose 15 soldiers, 150 feed and 3 horses in the skirmish.'
                  dc.b    $0D,$0A,0
                  
Continue_text:
                  dc.b    $0D,$0A
                  dc.b    'Ignoring the obvious trap, you decide to lead your army onwards towards'
                  dc.b    $0D,$0A
                  dc.b    'the mountains. As you walk past the clearing you see something fly through'
                  dc.b    $0D,$0A
                  dc.b    'the forest in the corner of your eye. As you look that direction, you'
                  dc.b    $0D,$0A
                  dc.b    'do not notice anything out of the ordinary. Convinced your mind must be'
                  dc.b    $0D,$0A
                  dc.b    'playing tricks on you, you march ahead towards the mountains.'
                  dc.b    $0D,$0A,0


Forest_right_path: 
                  dc.b    $0D,$0A
                  dc.b    'Not sure which way to go, you randomly pick the right path. As you'
                  dc.b    $0D,$0A
                  dc.b    'travel, you notice the road getting more and more waterlogged until'
                  dc.b    $0D,$0A
                  dc.b    'you reach what looks like a swamp. You carefully proceed through the'
                  dc.b    $0D,$0A
                  dc.b    'water, trying your best not to get stuck. As your army progress, you'
                  dc.b    $0D,$0A
                  dc.b    'notice tiny unnatural ripples in the water. Before you can shout a'
                  dc.b    $0D,$0A
                  dc.b    'warning, several of the horses in front of you suddenly fall into the'
                  dc.b    $0D,$0A
                  dc.b    'water, as if something dragged them in. As soon as this happens, about'
                  dc.b    $0D,$0A
                  dc.b    'twenty giant crab-like creatures known as chuul burst out of the water'
                  dc.b    $0D,$0A
                  dc.b    'with a primal hunger in their eyes. They seem to completely ignore you'
                  dc.b    $0D,$0A
                  dc.b    'and your army and move towards the submerged horses.'
                  dc.b    $0D,$0A
                  dc.b    $0D,$0A
                  dc.b    'What will you do?'
                  dc.b    $0D,$0A
                  dc.b    $0D,$0A
                  dc.b    '1. Leave the horses and try to get away'
                  dc.b    $0D,$0A
                  dc.b    '2. Try to save the horses and the soldiers on them'
                  dc.b    $0D,$0A,0
                  
Save_horses_msg:
                  dc.b    $0D,$0A
                  dc.b    'You immediately order your men to kill all the chuuls and pull out'
                  dc.b    $0D,$0A
                  dc.b    'the stuck horses. They sprint over and slay as many of them as they'
                  dc.b    $0D,$0A
                  dc.b    'can before trying to pull out the horses left alive after the attack.'
                  dc.b    $0D,$0A
                  dc.b    $0D,$0A
                  dc.b    'You lose 2 horses and 5 soldiers in the ambush'
                  dc.b    $0D,$0A,0
                  
Leave_horses_msg:
                  dc.b    $0D,$0A
                  dc.b    'You decide to play it save and sacrifice the men and horses for the'
                  dc.b    $0D,$0A
                  dc.b    'good of the kingdom and use this opportunity to lead your army to'
                  dc.b    $0D,$0A
                  dc.b    'safety.'
                  dc.b    $0D,$0A
                  dc.b    $0D,$0A
                  dc.b    'You sacrifice 5 horses to the chuuls'
                  dc.b    $0D,$0A,0
                  
                  *-----------------------------------
                  *------------Castle Text------------
                  *-----------------------------------
                  
Mountain_start_msg:
                  dc.b    $0D,$0A
                  dc.b    'You finally reach the end of the Lost Woods after several days of'
                  dc.b    $0D,$0A
                  dc.b    'travel. As you take your first step out into the sunlight, you are'
                  dc.b    $0D,$0A
                  dc.b    'greeted with a magnificent sight. A huge darkstone castle stands'
                  dc.b    $0D,$0A
                  dc.b    'before you bathed in a magical light, as if it is beyond some sort'
                  dc.b    $0D,$0A
                  dc.b    'of portal. You cautiously lead what remains of your army into the'
                  dc.b    $0D,$0A
                  dc.b    'portal and you are teleported to the top of the mountain you were'
                  dc.b    $0D,$0A
                  dc.b    'sent to investigate. The iron drawbridge slowly lowers in front'
                  dc.b    $0D,$0A
                  dc.b    'of you as a hooded figure becons you to enter the courtyard. You'
                  dc.b    $0D,$0A
                  dc.b    'slowly progress forward, as if guided by some sort of force, into'
                  dc.b    $0D,$0A
                  dc.b    'the courtyard of the castle where the drawbridge quickly raises behind'
                  dc.b    $0D,$0A
                  dc.b    'you and your army. You watch as the figure slowly raises his hand. As'
                  dc.b    $0D,$0A
                  dc.b    'he does, a horde of monsters flood the courtyard from all angles. They'
                  dc.b    $0D,$0A
                  dc.b    'encircle you and your army in seconds, leaving you no time to react.'
                  dc.b    $0D,$0A
                  dc.b    'You see the figure on the balcony slowly take off their hood to reveal'
                  dc.b    $0D,$0A
                  dc.b    'a dark elven face with long black hair and intense purple eyes. He looks'
                  dc.b    $0D,$0A
                  dc.b    'in your direction and as he opens his mouth you hear a deep, menacing'
                  dc.b    $0D,$0A
                  dc.b    'voice "You dare to bring an army here, into the plane of Beshaba, Lord'
                  dc.b    $0D,$0A
                  dc.b    'of Darkness and Deciet?"'
                  dc.b    $0D,$0A
                  dc.b    $0D,$0A
                  dc.b    'How will you respond?'
                  dc.b    $0D,$0A
                  dc.b    $0D,$0A
                  dc.b    '1. I have made a terrible mistake. Let me go back to my realm and I'
                  dc.b    $0D,$0A
                  dc.b    'shall never bother you again.'
                  dc.b    $0D,$0A
                  dc.b    $0D,$0A
                  dc.b    '2. I bring this army as a sacrifice to you, my lord.'
                  dc.b    $0D,$0A
                  dc.b    $0D,$0A
                  dc.b    '3. I do not care who you are, you are dying by my hand, demon'
                  dc.b    $0D,$0A,0
                  
Killed_msg:
                  dc.b    $0D,$0A
                  dc.b    'Before you even finish your sentence, the elf shoots a blue bolt of'
                  dc.b    $0D,$0A
                  dc.b    'lightning into your chest. As you fall, the last words you hear are,'
                  dc.b    $0D,$0A
                  dc.b    '"I do not show mercy, insolent mortal"'
                  dc.b    $0D,$0A
                  dc.b    $0D,$0A
                  dc.b    'GAME OVER'
                  dc.b    $0D,$0A,0

Captured_msg:     dc.b    $0D,$0A
                  dc.b    'The dread lord smiles as he sees you have remained faithful to him'
                  dc.b    $0D,$0A
                  dc.b    'as you have travelled. He gladly slaughters all of your army in'
                  dc.b    $0D,$0A
                  dc.b    'front of you. As he turns to you, he places his hand on your'
                  dc.b    $0D,$0A
                  dc.b    'shoulder and says "You have served me well mortal, however your'
                  dc.b    $0D,$0A
                  dc.b    'time on this plane is up. May you live forever in the void."'
                  dc.b    $0D,$0A
                  dc.b    'He reaches behind his back and stabs you with a cursed dagger.'
                  dc.b    $0D,$0A
                  dc.b    'As the darkness takes you, you finally feel at peace, content with'
                  dc.b    $0D,$0A
                  dc.b    'the fact that you sole duty to your lord has been fulfilled'
                  dc.b    $0D,$0A
                  dc.b    $0D,$0A
                  dc.b    'THE END - Bad End'
                  dc.b    $0D,$0A,0

fight_msg:        dc.b    $0D,$0A
                  dc.b    '"You unfaithful cur!" The dread lord pulls out his ebony greatsword and'
                  dc.b    $0D,$0A
                  dc.b    'leaps into the courtyard in front of you. His army of monsters moves'
                  dc.b    $0D,$0A
                  dc.b    'and ready themselves to attack.'
                  dc.b    $0D,$0A,0
                  
fight_won_msg:    dc.b    $0D,$0A
                  dc.b    'The battle is fierce. Your battle hardened warriors fight valiently in'
                  dc.b    $0D,$0A
                  dc.b    'your honour and soon it is just you, your army and the dread lord left'
                  dc.b    $0D,$0A
                  dc.b    'standing on the batlefield. You stare him in the eyes and say your last'
                  dc.b    $0D,$0A
                  dc.b    'words as commander, "Kill Him". You watch as you army charges past you'
                  dc.b    $0D,$0A
                  dc.b    'swarm the lord. Before he is dead you walk up to him, look him in the'
                  dc.b    $0D,$0A
                  dc.b    'eyes one last time, and bury you sword in his chest'
                  dc.b    $0D,$0A
                  dc.b    $0D,$0A
                  dc.b    'THE END - Good End'
                  dc.b    $0D,$0A,0

fight_lost_msg:   dc.b    $0D,$0A
                  dc.b    'You fight your best, but ultimately the dread lord and his army are too'
                  dc.b    $0D,$0A
                  dc.b    'strong for your small army to face and one by one they all fall. You are'
                  dc.b    $0D,$0A
                  dc.b    'the only one left standing among a sea of corpses as the dread lord'
                  dc.b    $0D,$0A
                  dc.b    'slowly walks towards you. He looks down on you in triumph and as he'
                  dc.b    $0D,$0A
                  dc.b    'lifts his sword to deal the final blow, he looks at you and whispers,'
                  dc.b    $0D,$0A
                  dc.b    '"May you live forever in the void, my dear".'
                  dc.b    $0D,$0A
                  dc.b    $0D,$0A
                  dc.b    'GAME OVER (need 25 soldiers to get good end)'  
                  
                  
Rest_msg:         dc.b    $0D,$0A
                  dc.b    'As the sun begins to set, you and your comerades decide to camp for'
                  dc.b    $0D,$0A
                  dc.b    'the night. You feed your horses and call it a night.'
                  dc.b    $0D,$0A,0
      
Horse_loss_msg:
                dc.b    $0D,$0A
                dc.b    'Horses without feed are lost.'
                dc.b    $0D,$0A,0
                
gameOver_msg_Soldiers:
                dc.b    $0D,$0A
                dc.b    'Tired after a long day, you decide to call it a night early and'
                dc.b    $0D,$0A
                dc.b    'make camp early. As dawn breaks, you find yourself feeling a'
                dc.b    $0D,$0A
                dc.b    'wierd coldness along your face. You jump awake and reach for'
                dc.b    $0D,$0A
                dc.b    'your sword, only to find that it, along with all your bags and'
                dc.b    $0D,$0A
                dc.b    'even the tent you were sleeping in, were stolen by what little remains'
                dc.b    $0D,$0A
                dc.b    'of your once great army. Guess mercenaries are not the wisest choice'
                dc.b    $0D,$0A
                dc.b    'when you want a loyal army.'
                dc.b    $0D,$0A
                dc.b    $0D,$0A
                dc.b    'GAME OVER - no soldiers'
                dc.b    $0D,$0A,0

gameOver_msg_Horses:
                dc.b    $0D,$0A
                dc.b    'As you set up your tent for the night, one of the soldiers sprints'
                dc.b    $0D,$0A
                dc.b    'over to you shouting "THE HORSES! THE HORSES!. You turn to see what'
                dc.b    $0D,$0A
                dc.b    'remains of your horses being chased by goblins into the forest and'
                dc.b    $0D,$0A
                dc.b    'out of view. You watch helplessly as your only means of travel disappear'
                dc.b    $0D,$0A
                dc.b    'into the horizon.'
                dc.b    $0D,$0A
                dc.b    $0D,$0A
                dc.b    'GAME OVER - no horses'
                dc.b    $0D,$0A,0
                


feed_msg:       dc.b    'Feed load (each horse needs at least 100 units of feed)'
                dc.b    $0D,$0A
                dc.b    'Enter feed load : ',0
                
current_feed_msg:       dc.b    'Current Feed: ',0

current_soldiers_msg:   dc.b    'Current Soldiers: ',0

continue_msg:   dc.b    'Press Enter to continue......',0
                     
                        
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
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
