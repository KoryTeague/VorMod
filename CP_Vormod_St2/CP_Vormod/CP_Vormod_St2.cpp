// CP_Vormod_St2.cpp : Single stage optimization problem representation of voronoi model (Vormod)
// Kory Teague
// Stage 2 only of CP_Vormod optimization model.  For solving the GA, first stage solution.

#include "stdafx.h"
#include <iostream>
#include "CP_Vormod.h"
#include <string.h>

ILOSTLBEGIN

static void readData(const char* filename, IloInt& S, IloInt& M, IloInt& O, IloNum& cap,
	IloNumArray& cost, IloNumArray& rateCap, IloNumArray& dem, IloNumArray& prob, IloNumArray& x, IloNumArray3& rateNorm);
void writeVal(const char* filename, IloNum val);
void writeVal(const char* filename, IloNumArray val);
void writeVal(const char* filename, IloNumArray3 val);
void writeVal(const char* filename, IloNum val1, IloNumArray3 val2);

int main(int argc, char **argv)
{
	IloEnv env;
	try {
		IloInt S, M, O;
		IloNum cap;
		IloNumArray cost(env), rateCap(env), dem(env), prob(env), x(env);
		IloNumArray3 rateNorm(env);

		IloNumVarArray3 del;

		string str1, str2;

		// Read Data
		if (argc > 1)
			readData(argv[1], S, M, O, cap, cost, rateCap, dem, prob, x, rateNorm);
		else
			readData("VorMod.dat", S, M, O, cap, cost, rateCap, dem, prob, x, rateNorm);

		// Define Decision Variables
		del = IloNumVarArray3(env, M);
		for (int m = 0; m < M; m++) {
			del[m] = IloNumVarArray2(env, S);
			for (int s = 0; s < S; s++) {
				del[m][s] = IloNumVarArray(env, O, 0, rateCap[s]);
			}
		}

		// Build Model
		IloModel model(env);

		// Add Objective Function
		IloExpr objFun(env);
		for (int s = 0; s < S; s++) {
			objFun += cost[s] * x[s];
		}
		for (int m = 0; m < M; m++) {
			for (int s = 0; s < S; s++) {
				for (int o = 0; o < O; o++) {
//					objFun -= prob[o] * del[m][s][o] * rateNorm[m][s][o] / cap;
					objFun -= prob[o] * del[m][s][o] * rateNorm[m][s][o];
				}
			}
		}
		model.add(IloMinimize(env, objFun));

		// Add Constraints
		for (int m = 0; m < M; m++) {
			for (int o = 0; o < O; o++) {
				IloExpr constraint(env);
				for (int s = 0; s < S; s++) {
					constraint += del[m][s][o] * rateNorm[m][s][o];
				}
				model.add(constraint <= dem[m]);
				constraint.end();
			}
		}

		for (int s = 0; s < S; s++) {
			for (int o = 0; o < O; o++) {
				IloExpr constraint(env);
				for (int m = 0; m < M; m++) {
					constraint += del[m][s][o];
				}
				model.add(constraint <= rateCap[s] * x[s]);
				constraint.end();
			}
		}

		// Generate and Add Model to Engine; Start Timer
		IloCplex cplex(model);
		IloNum runtime = cplex.getTime();
		cout << "Timer Started" << endl;
		cplex.setParam(IloCplex::TiLim, 900);

		// Export Model for Posterity
		str1 = "model.lp";
		cplex.exportModel(str1.c_str());

		// Solve Model
		cplex.solve();
		cout << "Model Solve Finished" << endl;

		// Write Model to File; Calculate Runtime
		IloNumArray3 tmpDel(env, M);
		for (int m = 0; m < M; m++) {
			tmpDel[m] = IloNumArray2(env, S);
			for (int s = 0; s < S; s++) {
				tmpDel[m][s] = IloNumArray(env, O);
				cplex.getValues(del[m][s], tmpDel[m][s]);
			}
		}

		runtime = cplex.getTime() - runtime;
		cout << "Runtime: " << runtime << " seconds" << endl << endl;

		if (argc > 1)
		{
			string fname(argv[1]);
			str1 = fname.substr(0, fname.find("."));
			str2 = str1 + "_out2del" + fname.substr(fname.find("."));
			writeVal(str2.c_str(), tmpDel);
			str2 = str1 + "_out2opt" + fname.substr(fname.find("."));
			writeVal(str2.c_str(), cplex.getObjValue());
			str2 = str1 + "_out2tim" + fname.substr(fname.find("."));
			writeVal(str2.c_str(), runtime);
			str2 = str1 + "_out2" + fname.substr(fname.find("."));
			writeVal(str2.c_str(), cplex.getObjValue(), tmpDel);
		}
		else
		{
			str1 = "VorMod_out2del.dat";
			writeVal(str1.c_str(), tmpDel);
			str1 = "VorMod_out2opt.dat";
			writeVal(str1.c_str(), cplex.getObjValue());
			str1 = "VorMod_out2tim.dat";
			writeVal(str1.c_str(), runtime);
			str1 = "VorMod_out2.dat";
			writeVal(str1.c_str(), cplex.getObjValue(), tmpDel);
		}

		// Garbage Collect (End Ilo Variables)
		cplex.end();
		objFun.end();
		model.end();
	}
	catch (IloException& ex) {
		cerr << "Error: " << ex << endl;
	}
	catch (...) {
		cerr << "Error: " << endl;
	}

	env.end();

    return 0;
}

static void readData(const char* filename, IloInt& S, IloInt& M, IloInt& O, IloNum& cap,
	IloNumArray& cost, IloNumArray& rateCap, IloNumArray& dem, IloNumArray& prob, IloNumArray& x, IloNumArray3& rateNorm)
{
	ifstream in(filename);
	if (in) {
		cout << "reading " << filename << endl;
		string tmpline;
		getline(in, tmpline);
		getline(in, tmpline);
		getline(in, tmpline);
		in >> S;
		cout << "reading S: " << S << endl;
		in >> M;
		cout << "reading M: " << M << endl;
		in >> O;
		cout << "reading O: " << O << endl;
		in >> cap;
		in >> cost;
		in >> rateCap;
		in >> dem;
		in >> prob;
		in >> x;
		in >> rateNorm;
		cout << "Done reading " << filename << endl;
	}
	else {
		cerr << "No such file: " << filename << endl;
		throw(1);
	}
	in.close();
}

void writeVal(const char* filename, IloNum val)
{
	ofstream out(filename, std::ios::trunc);

	if (out) {
		out << val << endl;
	}
	else {
		cerr << "Error writing file" << endl;
		throw(1);
	}

	out.close();
}

void writeVal(const char* filename, IloNumArray val)
{
	ofstream out(filename, std::ios::trunc);

	if (out) {
		out << val << endl;
	}
	else {
		cerr << "Error writing file" << endl;
		throw(1);
	}

	out.close();
}

void writeVal(const char* filename, IloNumArray3 val)
{
	ofstream out(filename, std::ios::trunc);
	
	if (out) {
		out << val << endl;
	}
	else {
		cerr << "Error writing file" << endl;
		throw(1);
	}
	out.close();
}

void writeVal(const char* filename, IloNum val1, IloNumArray3 val2)
{
	ofstream out(filename, std::ios::trunc);

	if (out) {
		out << val1 << endl << endl;
		out << val2 << endl;
	}
	else {
		cerr << "Error writing file" << endl;
		throw(1);
	}

	out.close();
}