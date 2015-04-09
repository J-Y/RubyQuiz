1. Directory structure and contents

README.txt
name_picker.rb*
data/
   attendees.txt*
   eligibles.yaml
   winners.yaml
images/
   LSRC_logo.gif*
   all_stars.gif*
   dim_stars.gif*
   stars_0.gif*
   stars_1.gif*
   stars_2.gif*
lib/
   picker_model.rb*
   picker_view.rb*

The files marked with stars (*) are essential. The application will not run without them. The only visible files allowed in /data are the three shown.
Further, both .yaml files must be present or neither.

2. Attendees.txt -- record format

Each record in the attendees database consists of three lines:

   <attendee name>
   <attendee affiliation>
   <blank line>

a. The file must end with a blank line.
b. If affiliation is unknown, enter -- (two dashes)

3. Winners.yaml

As a courtesy to the conference staff, a winners list is maintained in data/winners.yaml. This file can be processed as desired -- for example, to  post the list of winners on the conference web site.

4. Adjusting the tease time

How long the app teases the audience is determined by a random integer drawn each time the Pick-Winner button is clicked. The range from which the integer is drawn can be controlled be changing the values the constants PickerView::T_MIN and PickerView::T_MAX.

5. Editing the teaser messages

The messages shown in the teaser panel can be modified by editing PickerView::TEASERS.

6. Programmer's notes

a. The application does not modify attendees.txt.
b. Removing eligibles.yaml and winners.yaml will reset the application (all entries in attendees.txt become eligible again).
c. Multiple prizes may be awarded in one session. Just keep clicking on the Pick-Winner button.
d. winner.yaml is not used by the application. It is written out to allow additional processing of the winners list by some other application.
