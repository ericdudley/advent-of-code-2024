/**
    High-level solution:
    1. For each position, calculate a vector to all stations (grouped by frequency).
    2. For each frequency group, compare all stations, and match pairs who's vectors are parallel and have double magnitude.
 */

#include <iostream>
#include <fstream>
#include <map>
#include <algorithm>
using namespace std;

class Pos
{
public:
    int row;
    int col;
    char val;

    Pos(int row, int col, char val)
    {
        this->row = row;
        this->col = col;
        this->val = val;
    }

    friend std::ostream &operator<<(std::ostream &os, const Pos &obj)
    {
        os << "Pos(row: " << obj.row << ", col: " << obj.col << ", val: '" << obj.val << "')";
        return os;
    }
};

class Vec
{
public:
    Pos *from;
    Pos *to;

    Vec(Pos *from, Pos *to)
    {
        this->from = from;
        this->to = to;
    }

    double get_d_row()
    {
        return this->to->row - this->from->row;
    }

    double get_d_col()
    {
        return this->to->col - this->from->col;
    }

    double get_magnitude()
    {
        return sqrt(pow(this->get_d_row(), 2) +
                    pow(this->get_d_col(), 2));
    };

    double get_dot_product(Vec *other)
    {
        return (
            (this->get_d_row() * other->get_d_row() +
             this->get_d_col() * other->get_d_col()) /
            (this->get_magnitude() * other->get_magnitude()));
    }

    double get_cross_product(Vec *other)
    {
        double mag1 = this->get_magnitude();
        double mag2 = other->get_magnitude();
        double dot_product = std::clamp(this->get_dot_product(other), -1., 1.);
        double theta = acos(dot_product);

        return mag1 * mag2 * sin(theta);
    }

    friend std::ostream &operator<<(std::ostream &os, Vec &obj)
    {
        os << "Vec(d_row: " << obj.get_d_row() << ", d_col: " << obj.get_d_col() << ")";
        return os;
    }
};

typedef vector<Pos *> Row;
typedef vector<Row> Grid;

Grid parse_input(string file_name)
{
    string line_txt;
    ifstream file(file_name);

    Grid grid{};
    int row = 0;
    while (getline(file, line_txt))
    {
        vector<Pos *> positions{};
        for (int col = 0; col < line_txt.length(); col++)
        {
            char c = line_txt[col];
            Pos *pos = new Pos(row, col, c);
            positions.push_back(pos);
        }
        grid.push_back(positions);
        row += 1;
    }

    return grid;
}

// Small test to verify (magnitude, dot, and cross product calculations)
void run_pos_vec_tests()
{
    Pos p1 = Pos(0, 0, 'a');
    Pos p2 = Pos(2, 0, 'b');
    Pos p3 = Pos(0, 0, 'a');
    Pos p4 = Pos(0, 4, 'b');
    Vec v1 = Vec(&p1, &p2);
    Vec v2 = Vec(&p3, &p4);
}

void print_grid(Grid grid, vector<Pos *> extras)
{
    for (int row = 0; row < grid.size(); row += 1)
    {
        for (int col = 0; col < grid.size(); col += 1)
        {
            Pos *pos = grid[row][col];

            bool is_extra = false;
            for (int i = 0; i < extras.size(); i += 1)
            {
                Pos *extra = extras[i];
                if (pos->row == extra->row && pos->col == extra->col)
                {
                    is_extra = true;
                    break;
                }
            }

            if (is_extra && pos->val == '.')
            {
                cout << "#";
            }
            else
            {
                cout << pos->val;
            }
        }
        cout << std::endl;
    }
}

int main(int argc, char **argv)
{
    string file_name = argv[1];
    Grid grid = parse_input(file_name);

    // Build a map for all stations grouped by frequency
    map<char, vector<Pos *>> freq_groups{};
    for (int row = 0; row < grid.size(); row += 1)
    {
        for (int col = 0; col < grid[row].size(); col += 1)
        {
            Pos *pos = grid[row][col];
            if (pos->val == '.')
            {
                continue;
            }

            if (!freq_groups.count(pos->val))
            {
                vector<Pos *> new_vec{};
                freq_groups.insert({pos->val, new_vec});
            }

            freq_groups.at(pos->val).push_back(pos);
        }
    }

    // Go through each position and look for antinodes
    int antinode_count = 0;
    vector<Pos *> antinodes{};
    for (int row = 0; row < grid.size(); row += 1)
    {
        for (int col = 0; col < grid[row].size(); col += 1)
        {
            Pos *pos = grid[row][col];

            bool is_antinode = false;

            for (const auto &group : freq_groups)
            {
                // First calculate vectors to all stations in this group
                vector<Vec *> vecs{};
                for (const auto station_pos : group.second)
                {
                    Vec *vec = new Vec(pos, station_pos);
                    vecs.push_back(vec);
                }

                // Second comparse all vectors to see if this position will have an antinode
                for (int i = 0; i < vecs.size(); i += 1)
                {
                    for (int j = i + 1; j < vecs.size(); j += 1)
                    {
                        Vec *v1 = vecs[i];
                        double v1_mag = v1->get_magnitude();
                        Vec *v2 = vecs[j];
                        double v2_mag = v2->get_magnitude();
                        double cross_product = v1->get_cross_product(v2);

                        if (
                            // Part 1
                            // cross_product < 0.0001 &&
                            // (v2_mag * 2 - v1_mag < 0.0001 ||
                            //  v1_mag * 2 - v2_mag < 0.0001)

                            // Part 2
                            cross_product < 0.0001 ||
                            (v1_mag < 0.0001 || v2_mag < 0.0001))
                        {
                            is_antinode = true;
                            break;
                        }
                    }

                    if (is_antinode)
                    {
                        break;
                    }
                }

                if (is_antinode)
                {
                    break;
                }
            }

            if (is_antinode)
            {
                antinode_count += 1;
                antinodes.push_back(pos);
            }
        }
    }

    cout << "Antinode count: " << antinode_count << std::endl;
    print_grid(grid, antinodes);
    return 0;
}