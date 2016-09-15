#include<map>
#include <isam/glc.h>
#include<isam/isam.h>

using namespace std;
using namespace isam;

map<int, Node*> poses, landmarks;
list<Factor*> measurements, odometry;
Slam slam;

void setup_isam(){
    Pose2d_Node* new_pose_node = new Pose2d_Node();
    poses[0]=new_pose_node;

    // create a prior measurement (a factor)
    Pose2d origin(0., 0., 0.);
    Eigen::MatrixXd Q = 1e4*eye(3);
    Noise Qsqinf = Information(Q);
    Pose2d_Factor* prior = new Pose2d_Factor(new_pose_node, origin, Qsqinf);
    odometry.push_back(prior);
}

void add_odometry(string str){
    unsigned int idx0, idx1;
    double x, y, t, ixx, ixy, ixt, iyy, iyt, itt;
    int res = sscanf(str.c_str(), "%i %i %lg %lg %lg %lg %lg %lg %lg %lg %lg", &idx0, &idx1, &x, &y, &t, &ixx, &ixy, &ixt, &iyy, &iyt, &itt);
    if (res!=11) {
        cout << "Error while parsing ODOMETRY entry" << endl;
        exit(1);
    }

    Pose2d measurement(x, y, t);
    Eigen::MatrixXd sqrtinf(3,3);
    sqrtinf <<
          ixx, ixy, ixt,
          0.,  iyy, iyt,
          0.,   0., itt;

    Pose2d_Node* new_pose_node = new Pose2d_Node();
    poses[idx1]=new_pose_node;

    Pose2d_Pose2d_Factor* factor = new Pose2d_Pose2d_Factor(
          dynamic_cast<Pose2d_Node*>(poses[idx0]),
          dynamic_cast<Pose2d_Node*>(poses[idx1]),
          measurement, SqrtInformation(sqrtinf));
    odometry.push_back(factor);
}

void add_measurement(string str){
    unsigned int idx0, idx1;
    double x, y, ixx, ixy, iyy;
    int res = sscanf(str.c_str(), "%i %i %lg %lg %lg %lg %lg", &idx0, &idx1, &x, &y, &ixx, &ixy, &iyy);
    if (res!=7) {
        cout << "Error while parsing landmark measurement entry" << endl;
        exit(1);
    }

    Point2d measurement(x, y);
    Eigen::MatrixXd sqrtinf(2,2);
    sqrtinf <<
          ixx, ixy,
          0.,  iyy;

    Point2d_Node* new_point_node = NULL;
    if(!landmarks[idx1]){
        new_point_node = new Point2d_Node();
        landmarks[idx1]=new_point_node;
    }

    Pose2d_Point2d_Factor* factor = new Pose2d_Point2d_Factor(
          dynamic_cast<Pose2d_Node*>(poses[idx0]),
          dynamic_cast<Point2d_Node*>(landmarks[idx1]),
          measurement, SqrtInformation(sqrtinf));
    measurements.push_back(factor);
}

void load_graph(char* filename){
    ifstream file(filename);
    if(!file.is_open()){
      cout<<filename<<" is not open!"<<endl;
      exit(-1);
    }
    string str;
    getline(file,str);
    while (file.good()) {
        int res = str.find(' ');
        if (str[0] == 'E') {
            add_odometry(str.substr(res));
        }
        if(str[0]=='L'){
            add_measurement(str.substr((res)));
        }
        getline(file,str);
    }
    for(map<int,Node*>::iterator it=poses.begin();it!=poses.end();it++){
        slam.add_node(it->second);
    }
    for(list<Factor*>::iterator it=odometry.begin();it!=odometry.end();it++){
        slam.add_factor(*it);
    }
    for(map<int,Node*>::iterator it=landmarks.begin();it!=landmarks.end();it++){
        slam.add_node(it->second);
    }
    for(list<Factor*>::iterator it=measurements.begin();it!=measurements.end();it++){
        slam.add_factor(*it);
    }

    cout<<"loaded "<< poses.size()<<" poses and "<<odometry.size()<<" odometry"<<endl;
    cout<<"loaded "<< landmarks.size()<<" landmarks and "<<measurements.size()<<" measurements"<<endl;
}

void load_nodes(list<Node*>& node_remove, char* filename){
    ifstream file(filename);
    if(!file.is_open()){
      cout<<filename<<" is not open!"<<endl;
      exit(-1);
    }
    int node;
    while(file>>node){
        if(poses.find(node)!=poses.end())
            node_remove.push_back(poses[node]);
        if(landmarks.find(node)!=landmarks.end())
            node_remove.push_back(landmarks[node]);
    }
    cout<<"loaded "<<node_remove.size()<<" nodes to remove"<<endl;
}

void reduce_graph_glc(list<Node*>& node_remove){
    bool sparse = true;  // sparse approximate or dense exact
    for(list<Node*>::iterator it=node_remove.begin();it!=node_remove.end();it++){
        vector<Factor*> felim = glc_elim_factors (*it);
        //GLC_RootShift rs;
	//vector<Factor*> fnew = glc_remove_node (slam, *it, sparse, &rs); // root shifted
        vector<Factor*> fnew = glc_remove_node (slam, *it, sparse); // root not shifted
        cout<<"node "<<(*it)->unique_id()<<" remove "<<felim.size()<<" add "<<fnew.size()<<endl;
    }
    slam.batch_optimization();
}

int main(int argc, char *argv[]){
    if(argc<4){
        cout<<"not enough arguments!"<<endl
           <<"usage: sparse_graph_glc <g2o_file> <nodes_to_remove> <output_file>"<<endl;

    }

    setup_isam();
    load_graph(argv[1]);
    if(argv[4]=="true"){
	slam.batch_optimization();
    }else{
	slam.update();
    }

    list<Node*> node_remove;
    load_nodes(node_remove, argv[2]);


    reduce_graph_glc(node_remove);

    slam.save(argv[3]);
    return 0;
}
