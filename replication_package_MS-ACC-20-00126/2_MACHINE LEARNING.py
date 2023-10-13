from scipy.sparse import csc_matrix,csr_matrix
from sklearn.ensemble import RandomForestRegressor
from slda.topic_models import SLDA
import numpy as np

#### FUNCTION TO CREATE SPARSE MATRICES ####

def sparse_mat(data,depvars):
    row1 = []
    col1 = []
    data1 = []
    y = []
    
    for rownum,x in enumerate(data):
    
        depvar = float(depvars[rownum].strip())
        
        y.append(depvar)
        
        x = x.strip()
        elems = x.split(' ')
        
        for e,elem in enumerate(elems):
            
            colnum = int(elem.split(':')[0])
            value = float(elem.split(':')[1])
            
            row1.append(rownum)
            col1.append(colnum)
            data1.append(value)
            
    X = csc_matrix((data1, (row1, col1))) # Sparse matrix of rows (observations) and columns (independent variables)
    
    return X,y


#### LOAD THE SPARSE MATRIX FILES ####

data_train = open(directory+'data_train.txt').readlines() # These files contain the sparse ngram counts in the format --> ngram_index:ngram_count ngram_index:ngram_count ngram_index:ngram_count...
data_test = open(directory+'data_test.txt').readlines()

#### LOAD THE DEPENDENT VARIABLE FILES (I.E., CAR01) WHERE THE DEPENDENT VARIABLE IN EACH LINE CORRESPONDS TO THE SAME LINE IN THE DATA_TRAIN OR DATA_TEST FILE ####

depvars_train = open(directory+'depvars_train.txt').readlines()
depvars_test = open(directory+'depvars_test.txt').readlines()

#### CREATE X AND y SPARSE MATRICES ####

X_train,y_train = sparse_mat(data_train,depvars_train) 
X_test,y_test = sparse_mat(data_test,depvars_test)

###################### RANDOM FOREST ######################

#### RUN THE RANDOM FOREST REGRESSION ####

rf=RandomForestRegressor(n_estimators=5000,max_features='sqrt') # number of trees you build = n_estimators, max_features = how many independent variables to allow in each tree, or you can put in sqrt which uses the square root of the number of independent variables

rf=rf.fit(X_train,y_train)

#### FIT THE RANDOM FOREST REGRESSION TO THE TESTING SET TO OBTAIN OUT-OF-SAMPLE PREDICTIONS AND SAVE TO OUTPUT FILE ####
            
predictions=rf.predict(X_test)

file1 = open(directory+'mloutput_rf_car01.txt','w')
            
for p,prediction in enumerate(predictions):
    filename = filenames_test[p]
    file1.write(filename+'|'+str(prediction)+'\n')
    
file1.close()     

###################### SLDA ######################

#### SET PARAMETERS ####

V = --VOCAB-- # Vocabulary -- THIS IS THE NUMBER OF NGRAMS IN THE TRAINING DATASET -- REPLACE THIS WITH THE CORRECT NUMBER
K = 200 # number of topics
alpha = np.ones(K)
sigma2 = 0.25
nu2 = K

#### RUN THE SLDA ALGORITHM ####

_K = K
_alpha = alpha
_beta = np.repeat(0.01, V)
_mu = 0
_nu2 = nu2
_sigma2 = sigma2
n_iter = 150

slda = SLDA(_K, _alpha, _beta, _mu, _nu2, _sigma2, n_iter, seed=42)
slda.fit(X_train, y_train)

burn_in = max(n_iter - 100, int(n_iter / 2))
eta1 = slda.eta[burn_in:] # The burn_in just ignores the first several iterations as the program is still trying to figure things out
eta_pred = eta1.mean(axis=0) # These are the topic coefficients --> (mean(axis=0) just means to take the mean of each column in eta

#### FIT THE SLDA MODEL TO THE TESTING SET TO OBTAIN OUT-OF-SAMPLE PREDICTIONS AND SAVE TO OUTPUT FILE ####

thetas_test_slda = slda.transform(X_test)
y_slda = [np.dot(eta_pred, thetas_test_slda[i]) for i in range(len(filenames_test))]

file1 = open(directory+'mloutput_slda_car01.txt','w')

for fn,filename in enumerate(filenames_test):
    filename = filename.strip()
    predicted = y_slda[fn]
    file1.write(filename+'|'+str(predicted)+'\n')
    
file1.close()

###################### SVR ######################

#### FUNCTIONS TO COMPUTE THE EPSILON AND C PARAMETERS ####

def get_epsilon(X,ys,k):

    # Obtain the k nearest neighbors based on the closest euclidian distance
    
    nbrs = NearestNeighbors(n_neighbors=k+1).fit(X)
    distances, indices = nbrs.kneighbors(X)
    
    # Calculate the predicted yhat based on the ys of the k nearest neighbors
    
    yhats = []
    for ind,index in enumerate(indices):
        yneighbors = []
        for element in index:
            if element <> ind: # A neighbor can't be itself
                yneighbors.append(ys[element])
        yhat = sum(yneighbors)/float(len(yneighbors))
        yhats.append(yhat)

    # Compute epsilon (See Cherkassky and Ma)
    
    n = float(len(ys))
    k = float(k)
    sigma2 = (1/n)*(n**(.2)*k)/(n**(.2)*k - 1)*sum((x-y)**2 for x,y in zip(ys,yhats))
    sigma = math.sqrt(sigma2)
    paramepsilon = 3*sigma*math.sqrt(math.log(n)/n)
    
    return paramepsilon

def get_C(ys):
    
    mean = sum(ys)/len(ys)
    stddev = np.std(ys)
    paramC = max(abs(mean+3*stddev),abs(mean-3*stddev))
    
    return paramC

EPSILON_PARAM = get_epsilon(X_train,y_train,5)
C_PARAM = get_C(y_train)

#### RUN THE SVR ALGORITHM ####

# The SVM_light algorithm can be downloaded here: https://www.cs.cornell.edu/people/tj/svm_light/

# NOTE, THE TRAINING AND TESTING DATASETS MUST BE ALTERED SLIGHTLY FOR THE SVM-LIGHT PROGRAM TO INCLUDE THE DEPENDENT VARIABLE (E.G., CAR01) AT THE BEGINNING OF EACH LINE IN THE DATA_TRAIN.TXT AND DATA_TEST.TXT FILES

# TYPE THE FOLLOWING INTO THE COMMAND PROMPT, INSERTING THE CORRECT PATHS, C_PARAM, AND EPSILON_PARAM

# /path/to/svm_learn -z r -c C_PARAM -w EPSILON_PARAM "/path/to/data_train.txt" "/path/to/model"

#### FIT THE SVR MODEL TO THE TESTING SET TO OBTAIN OUT-OF-SAMPLE PREDICTIONS ####

# TYPE THE FOLLOWING INTO THE COMMAND PROMPT, INSERTING THE CORRECT PATHS

# /path/to/svm_classify "/path/to/data_test.txt" "/path/to/model" "/path/to/mloutput_svr_car01.txt"






