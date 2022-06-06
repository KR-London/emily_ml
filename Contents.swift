import Cocoa
import NaturalLanguage
import CreateML

var str = "Hello, playground"
var counter = 0

/// do I need some more data cleaning to remove blank poems?


struct Verse : Codable {
    
    var lines = [String]()
    var averagedWeight = [Double]()

    init(lines: [String]){
        
        self.lines = lines
        var weights = [[Double]]()
        for line in lines {

            if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english){

                if let vector = sentenceEmbedding.vector(for: line){
                    weights.append(vector)
                }
            }
        }

        for i in 0 ... weights[0].count - 1 {

            var average = 0.0
            
          
            for j in 0 ... weights.count - 1 {

                average += weights[j][i]

              }

            average = average / Double(weights.count)
            averagedWeight.append(average)
      }
        
       // print("Initialised poem number \(counter)")
        counter += 1
    }
}

var poemCollection = [Verse]()
var rawString = ""

if let filepath = Bundle.main.url(forResource: "Emily", withExtension: "tsv")
{
    do {
        rawString = try String(contentsOf: filepath)
        print("loaded data")
    } catch{
        print("oh no")
    }
}
else{
    print("Your filepath failed")
}
///remake the file without all the commas by taking it in from a single collumn

var unprocessedVerses = rawString.components(separatedBy: "\r\n\r\n")
//print(unprocessedVerses.first!)

for unprocessedVerse in unprocessedVerses {
//var lines = unprocessedVerses.first!.components(separatedBy: "\r\n")
    var lines = unprocessedVerse.components(separatedBy: "\r\n")
      
  //  print(lines.count)
        // initialise the verse object, including working out their average vector
    if lines.count > 1 {
        
        for i in 0 ... lines.count-1 {
           lines[i] = lines[i].replacingOccurrences(of: "\"", with: "")
           lines[i] = lines[i].replacingOccurrences(of: "T ", with: "It ")
           lines[i] = lines[i].trimmingCharacters(in: .whitespaces)
       }
        
        let verse = Verse(lines: lines)
        poemCollection.append(verse)
    }
}

var embeddingsDictionary = [String : [Double]]()

for poem in poemCollection{
    embeddingsDictionary[poem.lines.first!] = poem.averagedWeight
    print(poem.lines.first)
}

//do {
//    let encoder = JSONEncoder()
//    let data = try encoder.encode(embeddingsDictionary)
//    print(data)
//} catch {
//    error
//}

do{
    let embedding = try MLWordEmbedding(dictionary: embeddingsDictionary)
    try embedding.write(to: URL(fileURLWithPath: "/Users/kate/Desktop/Verse2.mlmodel"))
}
catch
{
    print(error.localizedDescription)
}
//let embedding = try! MLEmbedding(dictionary: embeddingsDictionary)

