#### OBTAIN NEGATIVE AND POSITIVE WORD LISTS FROM LOUGHRAN AND MCDONALD (2011) -- AVAILABLE HERE: https://drive.google.com/file/d/15UPaF2xJLSVz8DYuphierz67trCxFLcl/view?usp=sharing (SEE THE POSITIVE AND NEGATIVE TABS IN THE WORKBOOK)

negwords = [' abandon ',' abandonded '] # etc.
poswords = [' able ',' abundance '] # etc.

#### OBTAIN NEGATIVE AND POSITIVE WORD LISTS FROM HARVARD -- AVAILABLE HERE: http://www.wjh.harvard.edu/~inquirer/homecat.htm (See the Positiv and Negativ lists)

negwords_harvard = [' abandon ',' abandonment '] # etc.
poswords_harvard = [' abide ',' ability '] # etc.

#### SET DIRECTORY OF CONFERENCE CALL TEXT FILES AND DIRECTORY OF OUTPUT FILE

directory_cc = 'PATH_TO_CC_FILES'
directory_10K = 'PATH_TO_10K_FILES'
to directory = 'PATH_TO_OUTPUT_FILE'

#### INITIALIZE OUTPUT FILES AND INCLUDE HEADERS

with open('tone_cc.txt','w') as file1:
    file1.write('filename|tone_pos|tone_neg|tone|tone_posharvard|tone_negharvard|tone_harvard\n')

with open('tone_10K.txt','w') as file1:
    file1.write('filename|tone_pos|tone_neg|tone|tone_posharvard|tone_negharvard|tone_harvard\n')

#### ITERATE OVER EACH CONFERENCE CALL FILE

filenames = os.listdir(directory_cc)

for filename in filenames:

    data = open(directory_cc+filename).readlines()
    data = ' '.join(data)
    data = data.replace('\n',' ')

    wc = len(data.split(' '))

    #### CALCULATE LOUGHRAN AND MCDONALD TONE ####
    
    wc_pos = 0
    wc_neg = 0

    for negword in negwords:
        wc_neg = wc_neg + data.count(negword)
        
    for posword in poswords:
        wc_pos = wc_pos + data.count(posword)

    tone_pos = wc_pos/wc
    tone_neg = wc_neg/wc
    
    if (wc_pos+wc_neg) == 0:
        tone = 0
    else:
        tone = (wc_pos-wc_neg)/(wc_pos+wc_neg)

    #### CALCULATE HARVARD TONE ####
    
    wc_pos_h = 0
    wc_neg_h = 0

    for negword in negwords_harvard:
        wc_neg_h = wc_neg_h + data.count(negword)
        
    for posword in poswords_harvard:
        wc_pos_h = wc_pos_h + data.count(posword)

    tone_posharvard = wc_pos_h/wc
    tone_negharvard = wc_neg_h/wc
    
    if (wc_pos_h+wc_neg_h) == 0:
        tone_harvard = 0
    else:
        tone_harvard = (wc_pos_h-wc_neg_h)/(wc_pos_h+wc_neg_h)

    #### WRITE TO OUTPUT FILE ####
    
    with open('tone_cc.txt','a') as file1:   
        file1.write(filename+'|'+str(tone_pos)+'|'+str(tone_neg)+'|'+str(tone)+'|'+'|'+str(tone_posharvard)+'|'+str(tone_negharvard)+'|'+str(tone_harvard)+'\n')

#### ITERATE OVER EACH 10-K FILE

filenames = os.listdir(directory_10K)

for filename in filenames:

    data = open(directory_10K+filename).readlines()
    data = ' '.join(data)
    data = data.replace('\n',' ')

    wc = len(data.split(' '))

    #### CALCULATE LOUGHRAN AND MCDONALD TONE ####
    
    wc_pos = 0
    wc_neg = 0

    for negword in negwords:
        wc_neg = wc_neg + data.count(negword)
        
    for posword in poswords:
        wc_pos = wc_pos + data.count(posword)

    tone_pos = wc_pos/wc
    tone_neg = wc_neg/wc
    
    if (wc_pos+wc_neg) == 0:
        tone = 0
    else:
        tone = (wc_pos-wc_neg)/(wc_pos+wc_neg)

    #### CALCULATE HARVARD TONE ####
    
    wc_pos_h = 0
    wc_neg_h = 0

    for negword in negwords_harvard:
        wc_neg_h = wc_neg_h + data.count(negword)
        
    for posword in poswords_harvard:
        wc_pos_h = wc_pos_h + data.count(posword)

    tone_posharvard = wc_pos_h/wc
    tone_negharvard = wc_neg_h/wc
    
    if (wc_pos_h+wc_neg_h) == 0:
        tone_harvard = 0
    else:
        tone_harvard = (wc_pos_h-wc_neg_h)/(wc_pos_h+wc_neg_h)

    #### WRITE TO OUTPUT FILE ####
    
    with open('tone_10K.txt','a') as file1:   
        file1.write(filename+'|'+str(tone_pos)+'|'+str(tone_neg)+'|'+str(tone)+'|'+'|'+str(tone_posharvard)+'|'+str(tone_negharvard)+'|'+str(tone_harvard)+'\n')
