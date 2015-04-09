class PosixPangrams
  @pool = ['admin','alias','ar','asa','at','awk',
    'basename','batch','bc','bg',
    'c99','cal','cat','cd','cflow','chgrp','chmod','chown','cksum','cmp','comm','command','compress','cp','crontab','csplit','ctags','cut','cxref',
    'date','dd','delta','df','diff','dirname','du',
    'echo','ed','env','ex','expand','expr',
    'false','fc','fg','file','find','fold','fort77','fuser',
    'gencat','get','getconf','getopts','grep',
    'hash','head',
    'iconv','id','ipcrm','ipcs',
    'jobs','join',
    'kill',
    'lex','link','ln','locale','localedef','logger','logname','lp','ls',
    'm4','mailx','make','man','mesg','mkdir','mkfifo','more','mv',
    'newgrp','nice','nl','nm','nohup',
    'od',
    'paste','patch','pathchk','pax','pr','printf','prs','ps','pwd',
    'qalter','qdel','qhold','qmove','qmsg','qrerun','qrls','qselect','qsig','qstat','qsub',
    'read','renice','rm','rmdel','rmdir',
    'sact','sccs','sed','sh','sleep','sort','split','strings','strip','stty',
    'tabs','tail','talk','tee','test','time','touch','tput','tr','true','tsort','tty','type',
    'ulimit','umask','unalias','uname','uncompress','unexpand','unget','uniq','unlink','uucp','uudecode','uuencode','uustat','uux',
    'val','vi',
    'wait','wc','what','who','write',
    'xargs',
    'yacc','zcat']
  @letters = {}
  @wordcount = {}

  def PosixPangrams::justdoit
    @pool.each { |word| 
      word.each_byte { |letters|
        letters = letters.chr
        if @letters[letters].nil? 
          @letters[letters] = [word]
        else
          @letters[letters] << word if @letters[letters].index(word).nil?
        end
      }
    }

    ('a'..'z').each { |letter|
      @wordcount[letter] = @letters[letter].length
    }

    @wordcount = @wordcount.sort {|a,b| a[1]<=>b[1]}

    output = ""
    @wordcount.each { |letter|
      output += (@letters[letter[0]][rand(@letters[letter[0]].length)] + " ") if output.index(letter[0]).nil?
    }

    output.each { |word| print word + " " }
  end
end

PosixPangrams::justdoit();
