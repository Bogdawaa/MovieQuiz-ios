import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    
    // Индекс текущего вопроса
    private var currentQuestionIndex = 0
    
    // Счетчик правильных ответов
    private var correctAnswers = 0
    
    // общее кол-во вопросов
    private let questionAmount: Int = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // настройка индикатора загрузки
        activityIndicator.hidesWhenStopped = true
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        // алерт презентер
        alertPresenter = AlertPresenter(viewController: self)
        // контроллер статистики
        statisticService = StatisticServiceImplementation()

        showLoadingAnimation()
        questionFactory?.loadData()
    }
    
    // MARK: - public
    func didRecieveNextQuestion(question: QuizQuestion?) {
       guard let question = question else {
           return
       }
       currentQuestion = question
       let viewModel = convert(model: question)
       DispatchQueue.main.async { [weak self] in
           self?.show(quiz: viewModel)
       }
    }
    
    func didLoadFromServer() {
        activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - private
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questionAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
       // метод красит рамку
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // если ответ пользователя верный, увеличить счетчик
        if isCorrect {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
        }
        blockAnswerButtons(blockButtons: false)
    }
    
    // вызывает следующий вопрос или показывает результат квиза
    private func showNextQuestionOrResults() {
        
        // если последний вопрос
        if currentQuestionIndex == questionAmount - 1 {
            
            let bestGame = statisticService?.store(correct: correctAnswers, total: questionAmount)

            guard let gamesCount = statisticService?.gamesCount,
                  let bestGame = bestGame,
                  let totalAccuracy = statisticService?.totalAccuracy else {
                return
            }
            
            let text =
                """
                Вы ответили на: \(correctAnswers) из \(questionAmount)
                Количество сыгранных квизов: \(gamesCount)
                Рекорд: \(bestGame.correct)(\(bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", totalAccuracy))%
                """
            
            let alertModel = AlertModel(title: "Этот раунд окончен",
                                        message: text,
                                        buttonText: "Сыграть еще раз")
                
            // отобразить алерт
            alertPresenter?.show(in: self, alertModel: alertModel) { [weak self] _ in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                questionFactory?.requestNextQuestion()
            }
        }
        else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
        blockAnswerButtons(blockButtons: true)
    }
    
    // функция блокировки кнопок ответа на вопрос. Принимает булевый параметр - блокировать да/нет
    private func blockAnswerButtons(blockButtons: Bool) {
        yesButton.isEnabled = blockButtons
        noButton.isEnabled = blockButtons
    }
    
    private func showLoadingAnimation() {
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        let networkErrorModel = AlertModel(title: "Ошибка",
                                           message: message,
                                           buttonText: "Попробовать ещё раз")
        
        alertPresenter?.show(in: self, alertModel: networkErrorModel) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    //MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
}
