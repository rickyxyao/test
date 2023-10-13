import re
import string
from nltk.stem.porter import *
stemmer = PorterStemmer()
exclude = set(string.punctuation)

#### CREATE STOPWORDS DICTIONARY ####

stopwords = ['a','able','across','after','also','am','among','an','and','any','are','as','at','be','because','been','but','by','can','could','dear','did','do','does','either','else','ever','every','for','from','get','got','had','has','have','he','her','hers','him','his','how','however','i','if','in','into','is','it','its','just','let','like','likely','me','my','of','off','often','on','only','or','other','our','own','rather','said','say','says','she','should','since','so','some','than','that','the','their','them','then','there','these','they','this','tis','to','too','twas','us','wants','was','we','were','what','when','where','which','while','who','whom','why','will','with','would','yet','you','your']

stopwords_dict={}
for stopword in stopwords:
    stopwords_dict[stopword]=0

#### FUNCTIONS TO CLEAN PHRASES AND WORDS ####

def fix_phrases(section):
    section = section.replace("\t", " ")
    section = section.replace('U.S.', 'US')
    section = re.sub('(\d+)\.(\d+)','\g<1>\g<2>',section) # Remove periods from numbers -- 4.55 --> 455
    section = section.replace(".com", "com")
    section = section.replace("-", " ")
    section = section.replace('. .', '.')
    section = section.replace('.', 'XXYYZZ1')
    section = ''.join(ch for ch in section if ch not in exclude) #Delete all punctuation except periods
    section = section.replace('XXYYZZ1', '.')
    section = section.lower()
    section = re.sub(' +',' ',section) #Remove multiple spaces
    if section == '.': section = ''
    return section

def fixword(word):
        word = word.replace('\n','')
        if re.search('[0-9]',word) != None:
            word = '00NUMBER00' # Replace numbers with 000NUMBER000
        try:
            test = stopwords_dict[word]
            word = '_' # Replace stop words with _
        except Exception:
            donothing = 1
        try:
            word = stemmer.stem(word) # Stemp words
        except Exception:
            word = ''
        return word

#### LOAD FILES ####

directory = 'PATH_TO_CC_FILES'
to directory = 'PATH_TO_OUTPUT_FILES'

filenames = os.listdir(directory)

for filename in filenames:

    data = open(directory+filename).readlines()
    data = ' '.join(data)
    data = data.replace('\n',' ')
    data = fix_phrases(data)
    sentences = data.split('.')

    #### EXTRACT ALL ONE AND TWO WORD PHRASES ####

    onegrams = []
    twograms = []

    for sentence in sentences:
        
        sentence = sentence.replace('.','').strip()
        
        allwords = sentence.split(' ')

        for w,word in enumerate(allwords):
            word0 = fixword(allwords[w])
            try:
                word1 = fixword(allwords[w+1])
            except Exception:
                word1 = ''
                
            if word0.strip() != '.' and word0.strip() != '':
                onegrams.append(word0)

                if word1.strip() != '.' and word1.strip() != '':
                    twogram = word0+' '+word1
                    twograms.append(twogram)
                    
    #### SAVE NGRAMS TO OUTPUT FILE ####
                    
    filengram = open(todirectory+'NGRAMS_'+filename+'.txt','w')
            
    uniqueonegrams = list(set(onegrams))
    uniqueonegrams = sorted(uniqueonegrams)
    for uniqueonegram in uniqueonegrams:
        count = onegrams.count(uniqueonegram)
        filengram.write(uniqueonegram+'|'+repr(count)+'\n')
            
    uniquetwograms = list(set(twograms))
    uniquetwograms = sorted(uniquetwograms)
    for uniquetwogram in uniquetwograms:
        count = twograms.count(uniquetwogram)
        filengram.write(uniquetwogram+'|'+repr(count)+'\n')
        
    filengram.close()
