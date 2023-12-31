## arg must be model id + suffix _all_csym.dat, ie UNIPROT_VX_Y_all_csym.dat
args = commandArgs(trailingOnly=TRUE)


#path = "/data5/elevy/01_3dcomplexV0/results/005_syms/ananas_clashscore_allsymC_nodiso80/"
file = args[1]
print(file)

thr_clashes = 200

list_pdb = list()
#for (file in clashfiles) {
code = gsub("_all_csym.dat", "", basename(file))
#dat = read.table(paste0(path,file), header = T, fill = T, stringsAsFactors = F)
dat = read.table(paste0(file), header = T, fill = T, stringsAsFactors = F)
print(dat)

##print(list_pdb[[code]])
#}

if (nrow(dat) > 1) {
  dat = na.omit(dat)
  dat = dat[dat$clashscore<thr_clashes,] # Remove all clash scores above 100, considered as faulty structures
  dat = dat[order(dat$av.rmsd),] # Rank by rmsd, we just take best rmsd among the structures filtered on clashscore
  list_pdb[[code]] = dat
  best.rmsd = lapply(list_pdb, 
                     function(x) {
                       if (nrow(x) >= 1) {
                         bestrmsd = x[1,2]
                       } else {
                         bestrmsd = NA
                       }
                       return(bestrmsd)
                     })
  best.rmsd = unlist(best.rmsd)
  
  best.sym = lapply(list_pdb, 
                    function(x) {
                      print(x)
                      if (nrow(x) >= 1) {
                        best.sym = x[1,1]
                      } else {
                        best.sym = "NPS"
                      }
                      return(best.sym)
                    })
  best.sym = unlist(best.sym)
  print(best.sym)
  
  best.clash = lapply(list_pdb, 
                      function(x) {
                        if (nrow(x) >= 1) {
                          best.clash = x[1,3]
                        } else {
                          best.clash = NA
                        }
                        return(best.clash)
                      })
  best.clash = unlist(best.clash)
} else {
  best.sym = dat$symmetry
  best.rmsd = dat$av.rmsd
  best.clash = dat$clashscore
}

cat("\n===========================================\n")
print(best.sym)
print(best.rmsd)
print(best.clash)
cat("\n===========================================\n")


data.best = data.frame(code = code,
                       symmetry = best.sym,
                       rmsd = best.rmsd,
                       clash.score = best.clash)
print(data.best)
# print(paste0(dirname(file), "/", data.best$code, "_best_sym_clash.csv"))
# write.csv(data.best, file = paste0(dirname(file), "/", data.best$code, "_best_sym_clash.csv"), quote = F, row.names = F)

pdbnodiso3 = paste0(dirname(file), "/", data.best$code, ".pdb")
outpdb = paste0(dirname(file), "/", code, "_", best.sym, ".pdb")

cat("pdb nodiso3: ", pdbnodiso3, "\n")
cat("symmetry: ", best.sym, "\n")
cat("outfile: ", outpdb, "\n")

if (best.sym != "NPS" & best.sym != "c2") {
  cat(paste("$ANANAS" , pdbnodiso3, best.sym, "--symmetrize", outpdb, sep = " "), "\n")
  system(paste("$ANANAS" , pdbnodiso3, best.sym, "--symmetrize", outpdb, sep = " "))
}
