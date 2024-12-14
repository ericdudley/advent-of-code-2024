
import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

class Rule {

    int before;
    int after;

    public Rule(int before, int after) {
        this.before = before;
        this.after = after;
    }

    @Override public String toString() {
        return "before: " + this.before + " after: " + this.after;
    }
}

class Update {
    ArrayList<Integer> pages;
    Map<Integer, Integer> pagePositions;
    
    public Update(ArrayList<Integer> pages) {
        this.pages = pages;
        this.pagePositions = new HashMap<>();

        for(int i = 0; i < pages.size(); i += 1){
            this.pagePositions.put(pages.get(i), i);
        }
    }

    public boolean isValid(ArrayList<Rule> rules) {
        for(var rule: rules){
            // Skip rule, if contains pages that are not in this update.
            if(!this.pagePositions.containsKey(rule.before) || !this.pagePositions.containsKey(rule.after)){
                continue;
            }

            int beforePosition = this.pagePositions.get(rule.before);
            int afterPosition = this.pagePositions.get(rule.after);
            if(beforePosition > afterPosition){
                return false;
            }
        }

        // All relevant rules satisfied before/after conditions
        return true;
    }

    /**
     * Assumes that pages is always odd size.
     * @return
     */
    public int getMiddleValue() {
        return pages.get((pages.size() - 1) / 2);
    }

    /**
     * First ensure the numbers satisfy the rules, then return middle value.
     *
     * @return
     */
    public int getOrderedMiddleValue(ArrayList<Rule> rules) {
        while (!this.isValid(rules)) {
            for (var rule : rules) {
                // Skip rule, if contains pages that are not in this update.
                if (!this.pagePositions.containsKey(rule.before) || !this.pagePositions.containsKey(rule.after)) {
                    continue;
                }

                int beforePosition = this.pagePositions.get(rule.before);
                int afterPosition = this.pagePositions.get(rule.after);
                if (beforePosition > afterPosition) {
                    this.pagePositions.put(rule.before, afterPosition);
                    this.pagePositions.put(rule.after, beforePosition);
                    this.pages.set(beforePosition, rule.after);
                    this.pages.set(afterPosition, rule.before);
                }
            }
        }

        return this.getMiddleValue();
    }
}

class Data {

    ArrayList<Rule> rules;
    ArrayList<Update> updates;

    public Data(ArrayList<Rule> rules, ArrayList<Update> updates) {
        this.rules = rules;
        this.updates = updates;
    }

    public static Data parseInput(String fileName) {
        ArrayList<Rule> rules = new ArrayList<>();
        ArrayList<Update> updates = new ArrayList<>();
        File file = new File(fileName); 
        try (Scanner scanner = new Scanner(file)) {
            while (scanner.hasNextLine()) {
                String line = scanner.nextLine();

                // Rule
                if (line.contains("|")) {
                    String[] parts = line.split("\\|");
                    rules.add(new Rule(Integer.parseInt(parts[0]), Integer.parseInt(parts[1])));
                } // Update
                else if (line.contains(",")) {
                    String[] parts = line.split(",");
                    ArrayList<Integer> numbers = new ArrayList<>();
                    for(String part: parts){
                        numbers.add(Integer.parseInt(part));
                    }
                    updates.add(new Update(numbers));
                }

            }

            return new Data(rules, updates);

        } catch (FileNotFoundException e) {
            System.out.println("file not found");
            e.printStackTrace();
        }
        return new Data(rules, updates);
    }
}

public class Solution {

    public static void main(String[] args) {
        String fileName = args[0];
        Data data = Data.parseInput(fileName);
        int sumOfMiddleValues = 0;
        for(var update: data.updates) {
            sumOfMiddleValues += !update.isValid(data.rules) ? update.getOrderedMiddleValue(data.rules) : 0;
        }

        System.out.println("Sum of middle values: " + sumOfMiddleValues);
    }
}
