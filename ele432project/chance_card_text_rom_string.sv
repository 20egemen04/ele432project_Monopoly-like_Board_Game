// chance_card_text_rom_string.sv

module chance_card_text_rom_string # (
    parameter CARD_COUNT = 21,  // Number of chance cards
    parameter MAX_CHARS = 42    // Set this when you instantiate! Maximum 80 to fit on a 640 pixel screen with 8x8 font
) (
    input  logic         clk,
    input  logic [4:0]   card_id,       // Which card to read (1 to 21)
    output logic [((MAX_CHARS * 8) - 1):0] text_string_line_0,  // 42 characters * 8 bits
    output logic [((MAX_CHARS * 8) - 1):0] text_string_line_1,  // 42 characters * 8 bits
    output logic [((MAX_CHARS * 8) - 1):0] text_string_line_2,  // 42 characters * 8 bits
    output logic [((MAX_CHARS * 8) - 1):0] text_string_line_3    // 42 characters * 8 bits
);


    // ==========================================
    // 1. THE MEMORY VAULT (21 Cards, 42 Chars Max)
    // ==========================================
    // This creates a 2D array of 8-bit bytes. 
    // It will automatically synthesize into efficient Block RAM inside the FPGA.
    logic [0:(MAX_CHARS - 1)][7:0] card_strings [0:((CARD_COUNT * 4) - 1)]; // 21 cards, each with up to 42 characters (8 bits each)

    // ==========================================
    // 2. ROM INITIALIZATION (Quartus-Compliant Task)
    // ==========================================
    task load_card_data();

        // Temporary string variable used strictly during synthesis to load the memory
        string temp_str;

        // Now, load the actual card texts byte-by-byte.
        // The .len() function tells the loop exactly when the sentence ends.
        
        // Card 1
        temp_str = "1-NEW SEMESTER STARTS!"; // Card 1 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[0][j] = temp_str[j];
        temp_str = "ADVANCE TO START."; // Card 1 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[1][j] = temp_str[j];
        temp_str = "COLLECT YOUR $2000 KYK SCHOLARSHIP."; // Card 1 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[2][j] = temp_str[j];
        temp_str = " "; // Card 1 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[3][j] = temp_str[j];

        // Card 2
        temp_str = "2-FORGOT TO SAVE!"; // Card 2 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[4][j] = temp_str[j];
        temp_str = "YOUR ELECTRONIC CIRCUIT DESIGN SOFTWARE"; // Card 2 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[5][j] = temp_str[j];
        temp_str = "CRASHED AND YOU LOST YOUR SCHEMATIC."; // Card 2 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[6][j] = temp_str[j];
        temp_str = "GO BACK 3 SPACES."; // Card 2 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[7][j] = temp_str[j];

        // Card 3
        temp_str = "3-LOUD BANG!"; // Card 3 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[8][j] = temp_str[j];
        temp_str = "YOU PLUGGED A CAPACITOR IN BACKWARDS"; // Card 3 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[9][j] = temp_str[j];
        temp_str = "AND IT EXPLODED."; // Card 3 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[10][j] = temp_str[j];
        temp_str = "PAY $1000 FOR REPLACEMENT PARTS."; // Card 3 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[11][j] = temp_str[j];

        // Card 4
        temp_str = "4-NEED A BREAK!"; // Card 4 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[12][j] = temp_str[j];
        temp_str = "YOUR BRAIN IS FRIED FROM DIFF. EQUATIONS."; // Card 4 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[13][j] = temp_str[j];
        temp_str = "GO TO THE SILENT GARDEN TO TOUCH GRASS."; // Card 4 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[14][j] = temp_str[j];
        temp_str = "(IF YOU PASS START, COLLECT $2000.)"; // Card 4 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[15][j] = temp_str[j];

        // Card 5
        temp_str = "5-ALL-NIGHTER!"; // Card 5 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[16][j] = temp_str[j];
        temp_str = "YOU PULLED AN ALL-NIGHTER FOR FINALS."; // Card 5 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[17][j] = temp_str[j];
        temp_str = "ADVANCE TO THE STUDY ROOM."; // Card 5 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[18][j] = temp_str[j];
        temp_str = "(IF YOU PASS START, COLLECT $2000.)"; // Card 5 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[19][j] = temp_str[j];

        // Card 6
        temp_str = "6-MISSING SEMICOLON!"; // Card 6 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[20][j] = temp_str[j];
        temp_str = "YOU MISSED A SEMICOLON ON YOUR TOP MODULE,"; // Card 6 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[21][j] = temp_str[j];
        temp_str = "CAUSING A WALL OF 100 RED SYNTAX ERRORS."; // Card 6 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[22][j] = temp_str[j];
        temp_str = "PAY EACH PLAYER $500 TO DEBUG YOUR CODE."; // Card 6 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[23][j] = temp_str[j];

        // Card 7
        temp_str = "7-COORDINATE SYSTEM CHAOS!"; // Card 7 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[24][j] = temp_str[j];
        temp_str = "YOU FORGOT HOW TO DO COORDINATE SYSTEM"; // Card 7 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[25][j] = temp_str[j];
        temp_str = "TRANSFORMATION ON YOUR FINAL EXAM."; // Card 7 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[26][j] = temp_str[j];
        temp_str = "GO DIRECTLY TO THE MAKE-UP EXAM."; // Card 7 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[27][j] = temp_str[j];

        // Card 8
        temp_str = "8-SLEEP DEPRIVATION!"; // Card 8 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[28][j] = temp_str[j];
        temp_str = "YOU STUDIED FOR THREE DAYS STRAIGHT,"; // Card 8 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[29][j] = temp_str[j];
        temp_str = "BUT FELL ASLEEP AT YOUR FINAL."; // Card 8 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[30][j] = temp_str[j];
        temp_str = "GO DIRECTLY TO THE MAKE-UP EXAM."; // Card 8 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[31][j] = temp_str[j];

        // Card 9
        temp_str = "9-CALCULATOR IN DEGREES!"; // Card 9 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[32][j] = temp_str[j];
        temp_str = "YOU DID THE ENTIRE EXAM WITH YOUR"; // Card 9 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[33][j] = temp_str[j];
        temp_str = "CALCULATOR IN THE WRONG MODE."; // Card 9 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[34][j] = temp_str[j];
        temp_str = "PAY A $500 STUPIDITY TAX TO THE BANK."; // Card 9 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[35][j] = temp_str[j];

        // Card 10
        temp_str = "10-THE NATIONAL GRANT!"; // Card 10 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[36][j] = temp_str[j];
        temp_str = "YOUR UNDERGRADUATE RESEARCH PROJECT WAS"; // Card 10 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[37][j] = temp_str[j];
        temp_str = "OFFICIALLY APPROVED FOR A TUBITAK GRANT!"; // Card 10 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[38][j] = temp_str[j];
        temp_str = "COLLECT $1000 TO FUND YOUR RESEARCH."; // Card 10 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[39][j] = temp_str[j];

        // Card 11
        temp_str = "11-MERIT SCHOLARSHIP!"; // Card 11 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[40][j] = temp_str[j];
        temp_str = "AN INDEPENDENT EDUCATIONAL FOUNDATION HAS"; // Card 11 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[41][j] = temp_str[j];
        temp_str = "RECOGNIZED YOUR ACADEMIC SUFFERING."; // Card 11 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[42][j] = temp_str[j];
        temp_str = "COLLECT $1500 FROM THE BANK."; // Card 11 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[43][j] = temp_str[j];

        // Card 12
        temp_str = "12-THE GROUP CHAT HERO!"; // Card 12 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[44][j] = temp_str[j];
        temp_str = "YOU SHARED A PAST EXAM WITH YOUR FRIENDS"; // Card 12 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[45][j] = temp_str[j];
        temp_str = "BEFORE THE EXAM IN THE CLASS GROUP."; // Card 12 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[46][j] = temp_str[j];
        temp_str = "EVERY PLAYER GAVE YOU $500 AS A THANK YOU."; // Card 12 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[47][j] = temp_str[j];

        // Card 13
        temp_str = "13-LIBRARY MONOPOLY!"; // Card 13 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[48][j] = temp_str[j];
        temp_str = "YOU MANAGED TO SNAG A TABLE IN THE LIBRARY"; // Card 13 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[49][j] = temp_str[j];
        temp_str = "DURING FINALS WEEK."; // Card 13 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[50][j] = temp_str[j];
        temp_str = "COLLECT $400 FROM EVERYONE.";
        for (int j = 0; j < temp_str.len(); j++) card_strings[51][j] = temp_str[j];

        // Card 14
        temp_str = "14-CAMPUS CAT TAX!"; // Card 14 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[52][j] = temp_str[j];
        temp_str = "YOU COULDN'T RESIST BUYING SOME FOOD FOR"; // Card 14 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[53][j] = temp_str[j];
        temp_str = "THE CATS HANGING AROUND THE SILENT GARDEN."; // Card 14 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[54][j] = temp_str[j];
        temp_str = "PAY $500 TO THE BANK."; // Card 14 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[55][j] = temp_str[j];

        // Card 15
        temp_str = "15-THE FAST AND THE FURIOUS!"; // Card 15 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[56][j] = temp_str[j];
        temp_str = "YOU BOARDED THE CAMPUS BUS AND THE DRIVER"; // Card 15 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[57][j] = temp_str[j];
        temp_str = "DRIFTED EVERY CORNER LIKE A RALLY CAR."; // Card 15 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[58][j] = temp_str[j];
        temp_str = "ADVANCE TO THE METRO STOP."; // Card 15 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[59][j] = temp_str[j];

        // Card 16
        temp_str = "16-HUNGRY DURING LECTURE!"; // Card 16 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[60][j] = temp_str[j];
        temp_str = "YOUR STOMACH IS GROWLING LOUDER"; // Card 16 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[61][j] = temp_str[j];
        temp_str = "THAN THE PROFESSOR."; // Card 16 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[62][j] = temp_str[j];
        temp_str = "ADVANCE TO THE CENTRAL CAFETERIA."; // Card 16 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[63][j] = temp_str[j];

        // Card 17
        temp_str = "17-RUSH HOUR!"; // Card 17 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[64][j] = temp_str[j];
        temp_str = "THERE IS SO MUCH TRAFFIC AND YOU MISSED"; // Card 17 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[65][j] = temp_str[j];
        temp_str = "THE CAMPUS BUS, YOU NEED TO USE THE TAXI."; // Card 17 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[66][j] = temp_str[j];
        temp_str = "PAY $100 TO THE BANK."; // Card 17 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[67][j] = temp_str[j];

        // Card 18
        temp_str = "18-CAR-GO!"; // Card 18 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[68][j] = temp_str[j];
        temp_str = "YOUR FRIEND PICKED YOU UP WITH THEIR CAR."; // Card 18 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[69][j] = temp_str[j];
        temp_str = "ADVANCE TO THE BUS STOP."; // Card 18 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[70][j] = temp_str[j];
        temp_str = "AS THANK YOU PAY $500 TO THE NEXT PLAYER."; // Card 18 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[71][j] = temp_str[j];

        // Card 19
        temp_str = "19-WHOOPSIE!"; // Card 19 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[72][j] = temp_str[j];
        temp_str = "YOU DROPPED YOUR DE1-SOC BOARD,"; // Card 19 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[73][j] = temp_str[j];
        temp_str = "TEAMMATES AND PROFESSOR IS ANGRY AT YOU."; // Card 19 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[74][j] = temp_str[j];
        temp_str = "PAY $300 TO EVERYONE & $1000 TO THE BANK."; // Card 19 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[75][j] = temp_str[j];

        // Card 20
        temp_str = "20-COURSE OVER!"; // Card 20 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[76][j] = temp_str[j];
        temp_str = "GO TO THE BUS STATION."; // Card 20 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[77][j] = temp_str[j];
        temp_str = " "; // Card 20 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[78][j] = temp_str[j];
        temp_str = " "; // Card 20 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[79][j] = temp_str[j];

        // Card 21
        temp_str = "21-EXPEDITION!"; // Card 21 line 1
        for (int j = 0; j < temp_str.len(); j++) card_strings[80][j] = temp_str[j];
        temp_str = "GO TO THE METRO STATION."; // Card 21 line 2
        for (int j = 0; j < temp_str.len(); j++) card_strings[81][j] = temp_str[j];
        temp_str = " "; // Card 21 line 3
        for (int j = 0; j < temp_str.len(); j++) card_strings[82][j] = temp_str[j];
        temp_str = " "; // Card 21 line 4
        for (int j = 0; j < temp_str.len(); j++) card_strings[83][j] = temp_str[j];

    endtask

    initial begin
        // First, fill every single slot with a Blank Space (ASCII 0x20).
        // This ensures the VGA screen doesn't draw garbage characters when 
        // a sentence ends before reaching 42 characters.
        for (int i = 0; i < (CARD_COUNT * 4); i++) begin
            for (int j = 0; j < MAX_CHARS; j++) begin
                card_strings[i][j] = 8'h20;
            end
        end

        // Trigger the internal task to build our ROM contents at compile time
        load_card_data();
    end

    // ==========================================
    // 3. SYNCHRONOUS READ LOGIC
    // ==========================================
    always_ff @(posedge clk) begin
        // Safety check to ensure we only read valid memory bounds
        if (card_id >= 5'd1 && card_id <= 5'd21) begin
            // ((card_id - 1) * 4) finds the card starting row, then adds line offset
            text_string_line_0 <= card_strings[((card_id - 1) * 4)];
            text_string_line_1 <= card_strings[((card_id - 1) * 4) + 1];
            text_string_line_2 <= card_strings[((card_id - 1) * 4) + 2];
            text_string_line_3 <= card_strings[((card_id - 1) * 4) + 3];
        end else begin
            // Output a blank space if an invalid address is requested
            text_string_line_0 <= {MAX_CHARS{8'h20}};
            text_string_line_1 <= {MAX_CHARS{8'h20}};
            text_string_line_2 <= {MAX_CHARS{8'h20}};
            text_string_line_3 <= {MAX_CHARS{8'h20}};
        end
    end

endmodule