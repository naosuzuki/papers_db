import sys

#string = sys.argv[1]

string = "M.Kowalski, D.Rubin, G.Aldering, R.J.Agostinho, A.Amadon, R.Amanullah, C.Balland, K. Barbary, G.Blanc, P.J.Challis, A.Conley, N.V.Connolly, R.Covarrubias, K.S.Dawson, S.E.Deustua, R.Ellis, S.Fabbro, V.Fadeyev, X.Fan, B.Farris, G.Folatelli, B.L.Frye, G.Garavini, E.L.Gates, L.Germany, G.Goldhaber, B.Goldman, A.Goobar, D.E.Groom, J.Haissinski, D.Hardin, I.Hook, S.Kent, A.G.Kim, R.A.Knop, C.Lidman, E.V.Linder, J.Mendez, J.Meyers, G.J.Miller, M.Moniez, A.M.Mourao, H.Newberg, S.Nobili, P.E.Nugent, R.Pain, O.Perdereau, S.Perlmutter, M.M.Phillips, V.Prasad, R.Quimby, N.Regnault, J.Rich, E.P.Rubenstein, P.Ruiz-Lapuente, F.D.Santos, B.E.Schaefer, R.A.Schommer, R.C.Smith, A.M.Soderberg, A.L.Spadafora, L.G.Strolger, M. Strovink, N.B.Suntzeff, N.Suzuki, R.C.Thomas, N.A.Walton, L.Wang, W.M.Wood-Vasey"

string = string.split(',')

names = []
for name in string:
    name = name.strip()
    name = name.split('.')
    if len(name) == 3:
	names.append('{%s}, %s.~%s.'%(name[2].strip(),name[0].strip(),name[1].strip()))
    elif len(name) == 2:
	names.append('{%s}, %s.'%(name[1].strip(),name[0].strip()))
    else:
	print name,"OOPS!"

print ' and '.join(names)
	
    
