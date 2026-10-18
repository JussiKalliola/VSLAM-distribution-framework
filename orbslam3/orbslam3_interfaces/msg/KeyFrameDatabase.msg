#protected

#Associated vocabulary
#const ORBVocabulary* mpVoc;

#Inverted file
#std::vector<list<KeyFrame*> > mvInvertedFile;

#For save relation without pointer, this is necessary for save/load function
#std::vector<list<long unsigned int> > mvBackupInvertedFileId;

#Mutex
#std::mutex mMutex;
